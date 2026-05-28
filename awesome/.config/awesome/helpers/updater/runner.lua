-- helpers/updater/runner.lua
-- Manages launching / cancelling the pacman PTY wrapper process,
-- parsing its output, and responding to Y/n prompts.
--
-- Cancel design note
-- ------------------
-- pacman runs as root (pkexec setuid). User-space signals cannot reach it
-- (EPERM). The wrapper kills it by closing the PTY master fd, which causes
-- the kernel to send SIGHUP to the slave foreground process group —
-- a privilege-free kernel mechanism.
--
-- We trigger this by sending SIGTERM to the wrapper (user-owned), whose
-- signal handler closes the master and exits. The wrapper's true PID is
-- read from PID_FILE rather than trusting awful.spawn's return value, which
-- may be an intermediate shell or GLib handle.

local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

local cfg    = require("helpers.updater.config")
local state  = require("helpers.updater.state")
local status = require("helpers.updater.status")

local M = {}

-- ── Noise filter ──────────────────────────────────────────────────────────────
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
    local pkg = line:match("([%w%-_:%.]+%-x86_64)")
             or line:match("([%w%-_:%.]+%-any)")
    if pkg then state.current_package = pkg end

    local cur, total, size, unit, pct =
        line:match(
            "Total%s*%(%s*(%d+)%s*/%s*(%d+)%)%s+"
            .. "([%d%.]+)%s*(%a+)%s+[%d%.]+%s*%a+/s"
            .. "%s+%S+%s+%[.-%]%s*(%d+)%%")

    state.percent = pct

    if cur then
        local summary = string.format(
            "Downloading: %s (%s/%s)  |  %s %s  |  %s%%",
            state.current_package, cur, total, size, unit, pct)
        state.output = state.output:gsub("\nDownloading: [^\n]+$", "")
        state.output = state.output .. "\n" .. summary
        return
    end

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
        awesome.emit_signal("updater::prompt_needed")
    end
end

local function on_stderr(line)
    if is_noise(line) then return end
    state.output = state.output .. line .. "\n"
    status.refresh()
end

local function on_exit(_, code)
    state.running        = false
    state.pending_prompt = false

    awful.spawn.with_shell(
        "fuser -k " .. cfg.INPUT_FIFO ..
        " 2>/dev/null; rm -f " .. cfg.INPUT_FIFO ..
        " " .. cfg.PID_FILE)

    awesome.emit_signal("updater::prompt_hide")

    -- 143 = 128+SIGTERM: cancelled by user, not an error
    local cancelled = (code == 143 or code == -15)

    if cancelled then
        state.output = state.output .. "\nCancelled."
    elseif code == 0 then
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
        "rm -f " .. cfg.INPUT_FIFO .. " " .. cfg.PID_FILE ..
        " && mkfifo " .. cfg.INPUT_FIFO,
        function()
            awful.spawn.with_shell("sleep 86400 <>" .. cfg.INPUT_FIFO .. " &")

            -- The PID returned here is NOT used for cancellation —
            -- the wrapper writes its own PID to PID_FILE at startup.
            awful.spawn.with_line_callback(
                { "python3", cfg.WRAPPER_PATH },
                { stdout = on_stdout, stderr = on_stderr, exit = on_exit }
            )
        end)
end

function M.cancel()
    if not state.running then return end

    -- Optimistically update the UI immediately.
    state.running = false
    state.output  = state.output .. "\nCancelling..."
    status.refresh()
    awesome.emit_signal("updater::prompt_hide")

    -- Send SIGTERM to the wrapper (user-owned, so this always works).
    -- The wrapper's SIGTERM handler closes the PTY master fd.
    -- The kernel then sends SIGHUP to pacman's controlling terminal group.
    -- pacman dies even though it runs as root. on_exit() fires normally.
    awful.spawn.easy_async_with_shell(
        "cat " .. cfg.PID_FILE .. " 2>/dev/null",
        function(pid_str)
            local pid = pid_str and pid_str:match("(%d+)")
            if pid then
                awful.spawn.with_shell("kill -TERM " .. pid)
            else
                -- Fallback: wrapper crashed before writing PID file.
                awful.spawn.with_shell(
                    "pkill -TERM -f pacman_pty_wrapper.py 2>/dev/null")
            end
        end)
end

function M.answer_prompt(answer)
    awful.spawn.with_shell(
        string.format("printf '%s\\n' >%s", answer, cfg.INPUT_FIFO))
    state.pending_prompt = false
    awesome.emit_signal("updater::prompt_hide")
end

function M.check()
    awful.spawn.easy_async_with_shell(
        "checkupdates 2>/dev/null | wc -l",
        function(out)
            state.count = tonumber(out:match("%d+")) or 0
        end)
end

return M
