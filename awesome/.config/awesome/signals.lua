-- signals.lua
-- Screen and client signal handlers: wallpaper, tags, cursor, polybar wiring.
-- Depends on: cursor_path, cursor_size, tag_names  (config.lua)

local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local cursor_cmd = ("xsetroot -xcf %s %d"):format(cursor_path, cursor_size)

-- Set cursor once on startup
gears.timer.delayed_call(function()
  os.execute(cursor_cmd)
end)

-- {{{ Tag layouts
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
  })
end)
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper {
    screen = s,
    widget = {
      {
        image     = beautiful.wallpaper,
        upscale   = true,
        downscale = true,
        widget    = wibox.widget.imagebox,
      },
      valign = "center",
      halign = "center",
      tiled  = false,
      widget = wibox.container.tile,
    }
  }
end)
-- }}}

-- {{{ Tags
screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag(tag_names, s, awful.layout.suit.spiral.dwindle)
end)
-- }}}

-- {{{ Client manage
client.connect_signal("manage", function(c)
  os.execute(cursor_cmd)
  if c.class == "polybar" then
    c:buttons(awful.util.table.join(
      awful.button({}, 1, function() maximize(client.focus) end)
    ))
  end
end)
-- }}}
