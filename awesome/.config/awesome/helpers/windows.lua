-- helpers/windows.lua
-- Window management functions exposed globally via awesome-client.
-- Depends on: float_width, float_height  (config.lua)

local awful = require("awful")

function restore()
  local c = awful.client.restore()
  if c then
    c:activate { raise = true, context = "key.unminimize" }
  end
end

function restore_all()
  for c in awful.client.iterate(function(c)
    return c.screen == awful.screen.focused()
  end) do
    c.minimized = false
    c:activate { raise = true, context = "key.unminimized" }
  end
end

function maximize(c)
  c.maximized = not c.maximized
  c:raise()
end

function float(c)
  awful.client.floating.toggle(c)
  c.width  = float_width
  c.height = float_height
  awful.placement.centered(c)
end
