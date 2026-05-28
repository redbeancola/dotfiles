-- notifications.lua
-- Naughty notification display and routing rules.
-- Depends on: notif_*  (config.lua)

local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local naughty   = require("naughty")
local ruled     = require("ruled")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi

-- {{{ Defaults
naughty.config.defaults.ontop        = true
naughty.config.defaults.screen       = awful.screen.focused()
naughty.config.defaults.timeout      = notif_timeout
naughty.config.defaults.title        = "Notification"
naughty.config.defaults.position     = "top_right"
naughty.config.defaults.border_width = 0
beautiful.notification_spacing       = notif_spacing
-- }}}

-- {{{ Notification layout builder
local function create_notif(n)
  local has_icon = n.icon ~= nil

  local action_widget = {
    {
      {
        id     = "text_role",
        align  = "center",
        font   = notif_font_action,
        widget = wibox.widget.textbox,
      },
      margins = { left = dpi(notif_act_margin), right = dpi(notif_act_margin) },
      widget  = wibox.container.margin,
    },
    widget = wibox.container.background,
  }

  local actions = wibox.widget {
    notification = n,
    base_layout  = wibox.widget {
      spacing = dpi(notif_act_spacing),
      layout  = wibox.layout.flex.horizontal,
    },
    widget_template = action_widget,
    widget          = naughty.list.actions,
  }

  local function spacer(length, visible)
    return wibox.widget {
      forced_width = length,
      visible      = visible,
      layout       = wibox.layout.fixed.horizontal,
    }
  end

  local title = wibox.widget.textbox()
  title.font   = notif_font_title
  title.align  = "center"
  title.markup = n.title

  local message = wibox.widget.textbox()
  message.font   = notif_font_msg
  message.align  = "left"
  message.markup = n.message

  local icon = wibox.widget {
    nil,
    {
      {
        image   = n.icon,
        visible = has_icon,
        widget  = wibox.widget.imagebox,
      },
      strategy = "max",
      width    = dpi(notif_icon_size),
      height   = dpi(notif_icon_size),
      widget   = wibox.container.constraint,
    },
    expand = "none",
    layout = wibox.layout.align.vertical,
  }

  local container = wibox.widget {
    {
      title,
      {
        icon,
        spacer(dpi(notif_icon_gap), has_icon),
        message,
        layout = wibox.layout.fixed.horizontal,
      },
      actions,
      spacing = dpi(notif_act_spacing),
      layout  = wibox.layout.fixed.vertical,
    },
    margins = dpi(notif_padding),
    widget  = wibox.container.margin,
  }

  naughty.layout.box {
    notification    = n,
    type            = "notification",
    bg              = beautiful.bg,
    border_width    = 0,
    shape           = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, notif_corner_r)
    end,
    widget_template = {
      {
        {
          { widget = container },
          strategy = "max",
          width    = dpi(notif_width),
          height   = dpi(notif_height_max),
          widget   = wibox.container.constraint,
        },
        strategy = "min",
        width    = dpi(notif_width),
        height   = dpi(notif_height_min),
        widget   = wibox.container.constraint,
      },
      bg     = beautiful.bg,
      widget = wibox.container.background,
    }
  }
end
-- }}}

naughty.connect_signal("request::display", function(n)
  create_notif(n)
end)

ruled.notification.connect_signal("request::rules", function()
  ruled.notification.append_rule {
    rule       = {},
    properties = {
      screen           = awful.screen.focused(),
      implicit_timeout = notif_timeout,
    }
  }
end)
