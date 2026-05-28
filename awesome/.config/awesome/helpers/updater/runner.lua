-- helpers/updates/runner.lua
-- Manages launching / cancelling the pacman PTY wrapper process,
-- parsing its output, and responding to Y/n prompts.

local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

local cfg    = require("helpers.updates.config")
local state  = require("helpers.updates.state")
local status = require("helpers.updates.status")

local M = {}

-- ── Noise filter ──────────────────────────────────────────────────────────────
-- ksshaskpass/Qt/Wayland noise leaks onto the PTY slave (merged fds).
local NOISE_PATTERNS = {
    "Failed to create wl_display",
    "qt%.qpa%.plugin",
    "ksshaskpass:",
}

local function is_noise(line)
    if line:match("^%s*$") then return true end
    for _, pat in ipairs(NOISE_PATTERNS) do
        if line:match(pat) then return true end
    end
    return false
end

-- ── Output parsing ────────────────────────────────────────────────────────────
local function parse_stdout(line)
    -- Track current package name from download headers.
    local pkg = line:match("([%w%-_:%.]+%-x86_64)")
             or line:match("([%w%-_:%.]+%-any)")
    if pkg then state.current_package = pkg end

    -- Condense repetitive download-progress lines into one summary line.
    local cur, total, size, unit, pct =
        line:match(
            "Total%s*%(%s*(%d+)%s*/%s*(%d+)%)%s+"
            .. "([%d%.]+)%s*(%a+)%s+[%d%.]+%s*%a+/s"
            .. "%s+%S+%s+%[.-%]%s*(%d+)%%")

    state.percent = pct  -- may be nil between progress ticks; that's fine

    if cur then
        local summary = string.format(
            "Downloading: %s (%s/%s)  |  %s %s  |  %s%%",
            state.current_package, cur, total, size, unit, pct)
        state.output = state.output:gsub("\nDownloading: [^\n]+$", "")
        state.output = state.output .. "\n" .. summary
        return  -- don't fall through to the generic append
    end

    -- Skip raw progress/header lines; keep everything else.
    local is_progress = line:match("%a+/s") or line:match("%d+%%")
    local is_pkg_hdr  = line:match("%-x86_64") or line:match("%-any")
    if not is_progress and not is_pkg_hdr then
        state.output = state.output .. line .. "\n"
    end
end

-- ── Post-update recheck ───────────────────────────────────────────────────────
local function schedule_recheck()
    gears.timer.start_new(3, function()
        awful.spawn.easy_async_with_shell(
            "checkupdates 2>/dev/null | wc -l",
            function(out)
                state.count = tonumber(out:match("%d+")) or 0
                status.refresh()
            end)
        return false
    end)
end

-- ── Process callbacks ─────────────────────────────────────────────────────────
local function on_stdout(line)
    if is_noise(line) then return end
    parse_stdout(line)
    status.refresh()

    if line:match("%[[Yy]/[Nn]%]") then
        state.pending_prompt = true
        -- Delegate button creation to popup.lua via a signal so runner.lua
        -- does not need to depend on popup.lua (avoids circular require).
        awesome.emit_signal("updater::prompt_needed")
    end
end

local function on_stderr(line)
    if is_noise(line) then return end
    state.output = state.output .. line .. "\n"
    status.refresh()
end

local function on_exit(_, code)
    state.running       = false
    state.pending_prompt = false
    state.pid           = nil

    awful.spawn.with_shell(
        "fuser -k " .. cfg.INPUT_FIFO ..
        " 2>/dev/null; rm -f " .. cfg.INPUT_FIFO)

    awesome.emit_signal("updater::prompt_hide")

    if code == 0 then
        state.output = state.output .. "\nDone!"
        state.count  = 0
        naughty.notify({
            title   = "System Updated",
            text    = "All packages updated successfully.",
            urgency = "normal",
            icon    = "system-software-update",
            timeout = 5,
        })
    else
        state.output = state.output ..
            string.format("\nFailed (exit %d).", code)
        naughty.notify({
            title   = "Update Failed",
            text    = "Update aborted",
            urgency = "critical",
            timeout = 5,
        })
    end

    status.refresh()
    schedule_recheck()
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- Start a full system update. No-op if one is already running.
function M.start()
    if state.running then return end

    state.running         = true
    state.percent         = 0
    state.output          = ""
    state.pending_prompt  = false
    state.current_package = ""

    awesome.emit_signal("updater::prompt_hide")
    status.refresh()

    awful.spawn.easy_async_with_shell(
        "rm -f " .. cfg.INPUT_FIFO .. " && mkfifo " .. cfg.INPUT_FIFO,
        function()
            -- Keep the FIFO open so writers never get SIGPIPE.
            awful.spawn.with_shell("sleep 86400 <>" .. cfg.INPUT_FIFO .. " &")

            -- setsid puts the wrapper (and every child it spawns, including
            -- pkexec + pacman) into a new process group whose PGID equals the
            -- wrapper's PID.  Killing -PGID later reaches all of them.
            state.pid = awful.spawn.with_line_callback(
                { "setsid", "python3", cfg.WRAPPER_PATH },
                { stdout = on_stdout, stderr = on_stderr, exit = on_exit }
            )
        end)
end

--- Cancel a running update.
-- Sends SIGTERM to the entire process group (wrapper + pkexec + pacman).
function M.cancel()
    if not state.pid then return end

    -- PGID == PID because we launched with setsid.
    -- The negative sign tells kill(1) to target the group.
    awful.spawn.with_shell("kill -TERM -" .. state.pid .. " 2>/dev/null")

    state.running = false
    state.pid     = nil
    state.output  = state.output .. "\nCancelled."
    status.refresh()
end

--- Send a Y/n answer to the running process.
---@param answer string  "y" or "n"
function M.answer_prompt(answer)
    awful.spawn.with_shell(
        string.format("printf '%s\\n' >%s", answer, cfg.INPUT_FIFO))
    state.pending_prompt = false
    awesome.emit_signal("updater::prompt_hide")
end

--- Periodic availability check (called by the timer in init.lua).
function M.check()
    awful.spawn.easy_async_with_shell(
        "checkupdates 2>/dev/null | wc -l",
        function(out)
            state.count = tonumber(out:match("%d+")) or 0
        end)
end

return M
