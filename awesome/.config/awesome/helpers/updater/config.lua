-- helpers/updater/config.lua
-- All tuneable constants for the updater subsystem.
-- Override any of these globals from rc.lua before requiring the updater.

local M = {}

-- Paths
M.INPUT_FIFO   = "/tmp/pacman_input"
M.PID_FILE     = "/tmp/pacman_wrapper.pid"
M.WRAPPER_PATH = os.getenv("HOME") .. "/.config/awesome/helpers/updater/pacman_pty_wrapper.py"

-- Popup geometry  (fall back to global overrides set in rc.lua)
M.popup = {
    forced_width  = updater_forced_width  or 600,
    maximum_width = updater_maximum_width or 600,
    minimum_width = updater_minimum_width or 600,
    forced_height = updater_forced_height or 180,
    x             = updater_popup_x       or 5550,
    y             = updater_popup_y       or 60,
}

-- lxpolkit / pkexec auth dialog position
M.polkit = {
    x = updater_polkit_x or 5700,
    y = updater_polkit_y or 170,
}

-- How often to poll for available updates (seconds)
M.check_interval = updater_timeout or 600

return M
