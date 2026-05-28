-- awesome_mode: api-level=4:screen=on
pcall(require, "luarocks.loader")

-- Standard libraries
local gears          = require("gears")
local awful          = require("awful")
local beautiful      = require("beautiful")
local naughty        = require("naughty")
require("awful.autofocus")

-- {{{ Error handling
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title   = "Oops, an error happened" .. (startup and " during startup!" or "!"),
    message = message,
  }
end)
-- }}}

beautiful.init("~/.config/awesome/theme-def.lua")

require("config")        -- terminal, editor, modkey
require("helpers")       -- globals used by polybar via awesome-client
require("signals")       -- wallpaper, tags, manage
require("keys")          -- keybindings (global + client)
require("rules")         -- client/notification rules
require("notifications") -- naughty display
require("autostart")     -- spawn on startup

-- {{{ Garbage collection
collectgarbage("setpause", gc_pause)
collectgarbage("setstepmul", gc_stepmul)
gears.timer({
  timeout   = gc_interval,
  autostart = true,
  call_now  = true,
  callback  = function() collectgarbage("collect") end,
})
-- }}}
