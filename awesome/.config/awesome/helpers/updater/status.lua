-- helpers/updater/status.lua
-- Renders current state into the popup's status_text widget and

local gears    = require("gears")
local beautiful = require("beautiful")
local state    = require("helpers.updater.state")

local M = {}

-- Returns the last `n` lines of `str`.
local function tail_lines(str, n)
    local lines = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local out = {}
    for i = math.max(1, #lines - n + 1), #lines do
        table.insert(out, lines[i])
    end
    return table.concat(out, "\n")
end

--- Redraw the status widget and toggle button visibility.
function M.refresh()
    local st = state.status_text
    if not st then return end

    if state.running then
        local display = tail_lines(state.output, 7)
        if #display > 250 then
            display = "[...]\n" .. display:sub(-250)
        end
        st.markup =
            '<span color="#f9e2af">Updating...\n</span>' ..
            '<span color="#cdd6f4" font="Monospace 9">' ..
            gears.string.xml_escape(display) .. "</span>"

    elseif state.count == 0 then
        st.markup = '<span color="#a6e3a1">System is up to date</span>'

    else
        st.markup = string.format(
            '<span color="%s">%d update%s available</span>',
            beautiful.fg_normal or "#b4befe",
            state.count,
            state.count == 1 and "" or "s")
    end

    if state.update_btn_container then
        state.update_btn_container.visible =
            state.count > 0 and not state.running
    end
    if state.cancel_btn_container then
        state.cancel_btn_container.visible = state.running
    end
end

return M
