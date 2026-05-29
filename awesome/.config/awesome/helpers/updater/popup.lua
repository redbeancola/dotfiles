-- helpers/updater/popup.lua

local awful    = require("awful")
local wibox    = require("wibox")
local gears    = require("gears")
local beautiful = require("beautiful")

local cfg    = require("helpers.updater.config")
local state  = require("helpers.updater.state")
local status = require("helpers.updater.status")
local runner = require("helpers.updater.runner")

local M = {}

-- Y/n prompt buttons 
local function populate_yn_buttons()
    local container = state.prompt_btn_container
    if not container then return end
    container:reset()

    local choices = {
        { label = " Yes (Y) ", answer = "y", bg = "#a6e3a1", fg = "#11111b" },
        { label = " No (N) ",  answer = "n", bg = "#f38ba8", fg = "#11111b" },
    }

    for _, choice in ipairs(choices) do
        local btn = wibox.widget {
            widget = wibox.container.background,
            bg     = choice.bg,
            shape  = gears.shape.rounded_rect,
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    '<span color="%s"><b>%s</b></span>',
                    choice.fg, choice.label),
                font   = "Monospace 10",
                align  = "center",
            },
        }
        local answer = choice.answer
        btn:buttons(gears.table.join(
            awful.button({}, 1, function() runner.answer_prompt(answer) end)
        ))
        container:add(btn)
    end

    container.visible = true
end

-- Signal handlers (from runner.lua)
awesome.connect_signal("updater::prompt_needed", function()
    populate_yn_buttons()
end)

awesome.connect_signal("updater::prompt_hide", function()
    if state.prompt_btn_container then
        state.prompt_btn_container.visible = false
    end
end)

-- Popup construction
local function build_popup()
    -- Status text
    local st = wibox.widget {
        widget = wibox.widget.textbox,
        font   = "Monospace 9",
        wrap   = "word_char",
    }
    state.status_text = st

    -- "Update All" button
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
    update_btn:buttons(gears.table.join(
        awful.button({}, 1, runner.start)
    ))

    state.update_btn_container = wibox.widget {
        update_btn,
        margins = { left = 12, right = 12, bottom = 10 },
        widget  = wibox.container.margin,
        visible = state.count > 0 and not state.running,
    }

    -- "Cancel" button
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
        awful.button({}, 1, runner.cancel)
    ))

    state.cancel_btn_container = wibox.widget {
        cancel_btn,
        margins = { left = 12, right = 12, bottom = 10 },
        widget  = wibox.container.margin,
        visible = state.running,
    }

    -- Y/n prompt row
    state.prompt_btn_container = wibox.widget {
        layout  = wibox.layout.fixed.horizontal,
        spacing = 10,
        visible = false,
    }
    if state.pending_prompt then populate_yn_buttons() end

    local prompt_wrapper = wibox.widget {
        state.prompt_btn_container,
        halign = "center",
        layout = wibox.container.place,
    }

    -- Assemble popup
    local p = cfg.popup
    state.popup = awful.popup {
        widget = {
            {
                {
                    st,
                    margins = 12,
                    widget  = wibox.container.margin,
                },
                {
                    state.update_btn_container,
                    state.cancel_btn_container,
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
        forced_width  = p.forced_width,
        maximum_width = p.maximum_width,
        minimum_width = p.minimum_width,
        forced_height = p.forced_height,
        x             = p.x,
        y             = p.y,
        ontop         = true,
        visible       = true,
        shape         = gears.shape.rounded_rect,
    }

    status.refresh()
end

-- Public API

--- Toggle the popup open/closed.
function M.toggle()
    if state.popup then
        state.popup.visible = false
        state.popup         = nil
        -- Clear widget refs so build_popup() starts fresh next time.
        state.status_text          = nil
        state.update_btn_container = nil
        state.cancel_btn_container = nil
        state.prompt_btn_container = nil
    else
        build_popup()
    end
end

-- Legacy global expected by keybindings / widgets
function show_update_popup() M.toggle() end
function close_update_popup()
    if state.popup then
        state.popup.visible = false
        state.popup         = nil
    end
end

return M
