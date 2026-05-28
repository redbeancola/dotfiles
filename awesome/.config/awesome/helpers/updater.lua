-- helpers/updater.lua
-- some symbols here are intentionally global for calls via awesome-client

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

-- ── Public globals ────────────────────────────────────────────────────────────
update_count               = 0
update_percent             = 0
update_running             = false

-- ── Module state ──────────────────────────────────────────────────────────────
local update_popup         = nil
local update_output        = ""
local status_text          = nil
local update_btn_container = nil
local cancel_btn_container = nil
local prompt_btn_container = nil
local update_pid           = nil
local pending_prompt       = false
local current_package      = ""

local INPUT_FIFO = "/tmp/pacman_input"
local WRAPPER    = "/tmp/pacman_pty_wrapper.py"

local WRAPPER_SRC = [=[
#!/usr/bin/env python3
import errno, os, pty, re, select, signal, subprocess, sys

INPUT_FIFO = "/tmp/pacman_input"
ANSI_RE = re.compile('\x1b[^a-zA-Z]*[a-zA-Z]')

try:
    fifo_fd = os.open(INPUT_FIFO, os.O_RDONLY | os.O_NONBLOCK)
except OSError as e:
    sys.stderr.write("pacman-wrapper: cannot open FIFO: " + str(e) + "\n")
    sys.exit(1)

master_fd, slave_fd = pty.openpty()

proc = subprocess.Popen(
    ["pkexec", "pacman", "-Syu"],
    stdin=slave_fd, stdout=slave_fd, stderr=slave_fd,
    close_fds=True,
)
os.close(slave_fd)

def cleanup():
    try: proc.terminate()
    except Exception: pass
    for fd in (master_fd, fifo_fd):
        try: os.close(fd)
        except OSError: pass

signal.signal(signal.SIGTERM, lambda s, f: (cleanup(), sys.exit(1)))
signal.signal(signal.SIGINT,  lambda s, f: (cleanup(), sys.exit(1)))

line_buf = ""

def emit(raw_text):
    global line_buf
    text = ANSI_RE.sub("", raw_text)
    text = text.replace("\r\n", "\n")
    line_buf += text
    while "\n" in line_buf:
        line, line_buf = line_buf.split("\n", 1)
        sys.stdout.write(line + "\n")
        sys.stdout.flush()
    while "\r" in line_buf:
        line, line_buf = line_buf.rsplit("\r", 1)
        prev = line.rsplit("\r", 1)[-1] if "\r" in line else line
        if prev.strip():
            sys.stdout.write(prev + "\n")
            sys.stdout.flush()
    if line_buf and re.search(r"\[[Yy]/[Nn]\]\s*$", line_buf):
        sys.stdout.write(line_buf + "\n")
        sys.stdout.flush()
        line_buf = ""

running = True
while running:
    try:
        r, _, _ = select.select([master_fd, fifo_fd], [], [], 0.1)
    except (ValueError, OSError):
        break

    if master_fd in r:
        try:
            data = os.read(master_fd, 4096)
            emit(data.decode("utf-8", errors="replace"))
        except OSError as e:
            if e.errno == errno.EIO:
                running = False
            break

    if fifo_fd in r:
        try:
            data = os.read(fifo_fd, 256)
            if data:
                os.write(master_fd, data)
        except OSError:
            pass

    if proc.poll() is not None:
        try:
            while select.select([master_fd], [], [], 0.2)[0]:
                data = os.read(master_fd, 4096)
                if not data: break
                emit(data.decode("utf-8", errors="replace"))
        except OSError:
            pass
        running = False

if line_buf:
    sys.stdout.write(line_buf + "\n")
    sys.stdout.flush()

cleanup()
proc.wait()
sys.exit(proc.returncode)
]=]

-- ── Popup open / close ────────────────────────────────────────────────────────
function close_update_popup()
    if update_popup then
        update_popup.visible = false
        update_popup = nil
    end
end

-- ── Y/n buttons ───────────────────────────────────────────────────────────────
local function create_yn_buttons()
    if not prompt_btn_container then return end
    prompt_btn_container:reset()

    local opts = {
        { text = " Yes (Y) ", cmd = "y\\n", bg = "#a6e3a1", fg = "#11111b" },
        { text = " No (N) ",  cmd = "n\\n", bg = "#f38ba8", fg = "#11111b" },
    }
    for _, opt in ipairs(opts) do
        local btn = wibox.widget {
            widget = wibox.container.background,
            bg     = opt.bg,
            shape  = gears.shape.rounded_rect,
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    '<span color="%s"><b>%s</b></span>', opt.fg, opt.text),
                font   = "Monospace 10",
                align  = "center",
            },
        }
        local cmd = opt.cmd
        btn:buttons(gears.table.join(
            awful.button({}, 1, function()
                awful.spawn.with_shell(
                    string.format("printf '%s' >%s", cmd, INPUT_FIFO))
                pending_prompt = false
                if prompt_btn_container then
                    prompt_btn_container.visible = false
                end
            end)
        ))
        prompt_btn_container:add(btn)
    end
    prompt_btn_container.visible = true
end

-- ── Status text + visibility ──────────────────────────────────────────────────
local function refresh_status()
    if not status_text then return end

    if update_running then
        local lines = {}
        for line in update_output:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        local start   = math.max(1, #lines - 6)
        local display = ""
        for i = start, #lines do display = display .. lines[i] .. "\n" end
        if #display > 250 then display = "[...]\n" .. display:sub(-250) end
        status_text.markup =
            '<span color="#f9e2af">Updating...\n</span>' ..
            '<span color="#cdd6f4" font="Monospace 9">' ..
            gears.string.xml_escape(display) .. '</span>'

    elseif update_count == 0 then
        status_text.markup = '<span color="#a6e3a1">System is up to date</span>'
    else
        status_text.markup = string.format(
            '<span color="%s">%d update%s available</span>', beautiful.fg_normal or "#b4befe",
            update_count, update_count == 1 and "" or "s")
    end

    if update_btn_container then
        update_btn_container.visible = update_count > 0 and not update_running
    end
    if cancel_btn_container then
        cancel_btn_container.visible = update_running
    end
end

-- ── Noise patterns that leak from ksshaskpass/Qt through the PTY ──────────────
-- Because all fds are merged onto the PTY slave, these appear on stdout.
local function is_noise(line)
    return line:match("Failed to create wl_display")
        or line:match("qt%.qpa%.plugin")
        or line:match("ksshaskpass:")
        or line:match("^%s*$")   -- blank lines produced by Qt init
end

-- ── Start update ──────────────────────────────────────────────────────────────
local function start_update()
    if update_running then return end

    local f = io.open(WRAPPER, "w")
    if not f then return end
    f:write(WRAPPER_SRC)
    f:close()

    update_running = true
    update_percent = 0
    update_output  = ""
    pending_prompt = false
    current_package = ""
    if prompt_btn_container then prompt_btn_container.visible = false end
    refresh_status()

    awful.spawn.easy_async_with_shell(
        "rm -f " .. INPUT_FIFO .. " && mkfifo " .. INPUT_FIFO,
        function()
            awful.spawn.with_shell("sleep 86400 <>" .. INPUT_FIFO .. " &")

            update_pid = awful.spawn.with_line_callback(
                { "python3", WRAPPER },
                {
                    stdout = function(line)
                        -- Drop ksshaskpass / Qt / Wayland noise.
                        -- All fds share the PTY slave so these arrive here,
                        -- not on stderr.
                        if is_noise(line) then return end

                        -- Condense download progress lines.
                        local pkg = line:match("([%w%-_:%.]+%-x86_64)")
                                 or line:match("([%w%-_:%.]+%-any)")
                        if pkg then current_package = pkg end

                        local cur, total, size, unit, pct =
                            line:match(
                                "Total%s*%(%s*(%d+)%s*/%s*(%d+)%)%s+"
                                .. "([%d%.]+)%s*(%a+)%s+[%d%.]+%s*%a+/s"
                                .. "%s+%S+%s+%[.-%]%s*(%d+)%%")
                        update_percent = pct -- accessed globally

                        if cur then
                            local summary = string.format(
                                "Downloading: %s (%s/%s)  |  %s %s  |  %s%%",
                                current_package, cur, total, size, unit, pct)
                            update_output = update_output:gsub(
                                "\nDownloading: [^\n]+$", "")
                            update_output = update_output .. "\n" .. summary
                        else
                            local is_progress = line:match("%a+/s")
                                             or line:match("%d+%%")
                            local is_pkg_hdr  = line:match("%-x86_64")
                                             or line:match("%-any")
                            if not is_progress and not is_pkg_hdr then
                                update_output = update_output .. line .. "\n"
                            end
                        end

                        refresh_status()

                        if line:match("%[[Yy]/[Nn]%]") then
                            pending_prompt = true
                            create_yn_buttons()
                        end
                    end,

                    stderr = function(line)
                        if is_noise(line) then return end
                        update_output = update_output .. line .. "\n"
                        refresh_status()
                    end,

                    exit = function(_, code)
                        update_running = false
                        pending_prompt = false
                        update_pid     = nil

                        awful.spawn.with_shell(
                            "fuser -k " .. INPUT_FIFO ..
                            " 2>/dev/null; rm -f " .. INPUT_FIFO)

                        if prompt_btn_container then
                            prompt_btn_container.visible = false
                        end

                        if code == 0 then
                            update_output = update_output .. "\nDone!"
                            update_count  = 0
                            naughty.notify({
                                title   = "System Updated",
                                text    = "All packages updated successfully.",
                                urgency = "normal",
                                icon    = "system-software-update",
                                timeout = 5,
                            })
                        else
                            update_output = update_output ..
                                string.format("\nFailed (exit %d).", code)
                            naughty.notify({
                                title   = "Update Failed",
                                text    = "Update aborted",
                                urgency = "critical",
                                timeout = 5,
                            })
                        end

                        refresh_status()

                        gears.timer.start_new(3, function()
                            awful.spawn.easy_async_with_shell(
                                "checkupdates 2>/dev/null | wc -l",
                                function(out)
                                    update_count = tonumber(out:match("%d+")) or 0
                                    refresh_status()
                                end)
                            return false
                        end)
                    end,
                }
            )
        end)
end

-- ── Build popup ───────────────────────────────────────────────────────────────
local function build_popup()
    status_text = wibox.widget {
        widget = wibox.widget.textbox,
        font   = "Monospace 9",
        wrap   = "word_char",
    }

    local update_btn = wibox.widget {
        widget = wibox.container.background,
        bg     = "#313244",
        shape  = gears.shape.rounded_rect,
        {
            widget = wibox.widget.textbox,
            markup = '<span color="#a6e3a1">  Update All  </span>',
            font   = "Monospace 10",
            align  = "center",
        },
    }
    update_btn:buttons(gears.table.join(awful.button({}, 1, start_update)))

    update_btn_container = wibox.widget {
        update_btn,
        margins = { left = 12, right = 12, bottom = 10 },
        widget  = wibox.container.margin,
        visible = update_count > 0 and not update_running,
    }

    local cancel_btn = wibox.widget {
        widget = wibox.container.background,
        bg     = "#313244",
        shape  = gears.shape.rounded_rect,
        {
            widget = wibox.widget.textbox,
            markup = '<span color="#f38ba8">  Cancel  </span>',
            font   = "Monospace 10",
            align  = "center",
        },
    }
    cancel_btn:buttons(gears.table.join(
        awful.button({}, 1, function()
            if update_pid then
                awful.spawn.with_shell("kill -TERM " .. update_pid)
                update_running = false
                update_pid     = nil
                update_output  = update_output .. "\nCancelled."
                refresh_status()
            end
        end)
    ))

    cancel_btn_container = wibox.widget {
        cancel_btn,
        margins = { left = 12, right = 12, bottom = 10 },
        widget  = wibox.container.margin,
        visible = update_running,
    }

    prompt_btn_container = wibox.widget {
        layout  = wibox.layout.fixed.horizontal,
        spacing = 10,
        visible = false,
    }

    if pending_prompt then create_yn_buttons() end

    local prompt_wrapper = wibox.widget {
        prompt_btn_container,
        halign = "center",
        layout = wibox.container.place,
    }

    update_popup = awful.popup {
        widget = {
            {
                {
                    status_text,
                    margins = 12,
                    widget  = wibox.container.margin,
                },
                {
                    update_btn_container,
                    cancel_btn_container,
                    prompt_wrapper,
                    layout = wibox.layout.fixed.vertical,
                },
                layout = wibox.layout.fixed.vertical,
            },
            bg     = beautiful.bg_focus or "#1e1e2e",
            widget = wibox.container.background,
        },
        border_color  = beautiful.border_normal or "#1e1e2e",
        border_width  = 0,
        forced_width  = updater_forced_width or 600,
        maximum_width = updater_maximum_width or 600,
        minimum_width = updater_minimum_width or 600,
        forced_height = updater_forced_height or 180,
        x             = updater_popup_x or 5550,
        y             = updater_popup_y or 60,
        ontop         = true,
        visible       = true,
        shape         = gears.shape.rounded_rect,
    }

    refresh_status()
end

-- ── Public toggle ─────────────────────────────────────────────────────────────
function show_update_popup()
    if update_popup then
        close_update_popup()
        return
    end
    build_popup()
end

-- ── Periodic update check ─────────────────────────────────────────────────────
local function check_updates()
    awful.spawn.easy_async_with_shell(
        "checkupdates 2>/dev/null | wc -l",
        function(stdout)
            update_count = tonumber(stdout:match("%d+")) or 0
        end)
end

gears.timer {
    timeout   = updater_timeout or 600,
    call_now  = true,
    autostart = true,
    callback  = check_updates,
}

-- lxpolkit window location, please move to rules.lua
ruled = require("ruled")
ruled.client.append_rule {
    id = "lxpolkit_fixed",
    rule_any = {
        class = { "lxpolkit", "Lxpolkit" }
    },
    properties = {
        floating = true,
        ontop    = true,
        -- Prevents the window from maximizing or stretching
        maximized = false,
        maximized_horizontal = false,
        maximized_vertical = false,
    },
    callback = function(c)
        -- Set your absolute target X and Y coordinates here
        local target_x = updater_polkit_x or 5700
        local target_y = updater_polkit_y or 170
        
        c:geometry({
            x = target_x,
            y = target_y
        })
    end
}
