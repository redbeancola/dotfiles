-- keys.lua
-- Global keybindings, client keybindings, and mouse bindings.
-- Depends on globals: modkey, terminal, cw, close_all_menus, restore,
-- restore_all, maximize, float  (defined in config.lua / helpers.lua)

local awful          = require("awful")
local hotkeys_popup  = require("awful.hotkeys_popup")

-- {{{ Global mouse bindings
awful.mouse.append_global_mousebindings({
  awful.button({}, 3, function()
    close_all_menus()
    awful.spawn.with_shell("sh ~/.config/rofi/launcher.sh apps")
  end),
  awful.button({}, 1, function()
    close_all_menus()
  end),
})
-- }}}

-- {{{ Global keybindings
awful.keyboard.append_global_keybindings({

  -- Awesome ------------------------------------------------------------------
  awful.key({ modkey },           "s",      hotkeys_popup.show_help,
    { description = "show help",       group = "awesome" }),
  awful.key({ modkey, "Control" }, "r",     awesome.restart,
    { description = "reload awesome",  group = "awesome" }),
  awful.key({ modkey },           "Return", function() awful.spawn(terminal) end,
    { description = "open terminal",   group = "launcher" }),

  -- Media --------------------------------------------------------------------
  awful.key({},           "XF86AudioRaiseVolume",  function() awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%")  end, { description = "volume +5%",  group = "media" }),
  awful.key({ "Control"}, "XF86AudioRaiseVolume",  function() awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +1%")  end, { description = "volume +1%",  group = "media" }),
  awful.key({},           "XF86AudioMute",         function() awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle") end, { description = "mute toggle", group = "media" }),
  awful.key({},           "XF86AudioLowerVolume",  function() awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%")  end, { description = "volume -5%",  group = "media" }),
  awful.key({ "Control"}, "XF86AudioLowerVolume",  function() awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -1%")  end, { description = "volume -1%",  group = "media" }),
  awful.key({}, "F6", function() awful.util.spawn("playerctl play-pause", false) end),
  awful.key({}, "F7", function() awful.util.spawn("playerctl previous",   false) end),
  awful.key({}, "F8", function() awful.util.spawn("playerctl next",       false) end),
  awful.key({}, "XF86MonBrightnessDown", function() awful.util.spawn("brightnessctl s 10%-") end),
  awful.key({}, "XF86MonBrightnessUp",   function() awful.util.spawn("brightnessctl s +10%") end),

  -- Tags ---------------------------------------------------------------------
  awful.key({ modkey }, "Left",   awful.tag.viewprev,        { description = "view previous", group = "tag" }),
  awful.key({ modkey }, "Right",  awful.tag.viewnext,        { description = "view next",     group = "tag" }),
  awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back",       group = "tag" }),

  -- Focus --------------------------------------------------------------------
  awful.key({ "Mod1" },          "Tab",   function() awful.client.focus.byidx( 1) end, { description = "focus next",     group = "client" }),
  awful.key({ "Mod1", "Shift" }, "Tab",   function() awful.client.focus.byidx(-1) end, { description = "focus previous", group = "client" }),
  awful.key({ modkey },          "j",     function() awful.client.focus.byidx( 1) end, { description = "focus next",     group = "client" }),
  awful.key({ modkey },          "k",     function() awful.client.focus.byidx(-1) end, { description = "focus previous", group = "client" }),
  awful.key({ modkey, "Control" }, "j",   function() awful.screen.focus_relative( 1) end, { description = "next screen",     group = "screen" }),
  awful.key({ modkey, "Control" }, "k",   function() awful.screen.focus_relative(-1) end, { description = "previous screen", group = "screen" }),
  awful.key({ modkey, "Tab" },     "Tab", function() awful.screen.focus_relative( 1) end, { description = "next screen",     group = "screen" }),
  awful.key({ modkey, "Control" }, "n",   function() restore()     end, { description = "restore minimized",     group = "client" }),
  awful.key({ modkey, "Mod1" },    "n",   function() restore_all() end, { description = "restore all minimized", group = "client" }),

  -- Layout -------------------------------------------------------------------
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx( 1) end, { description = "swap with next",     group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end, { description = "swap with previous", group = "client" }),

  -- Launchers ----------------------------------------------------------------
  awful.key({ modkey },           "a", function() awful.spawn.with_shell("sh ~/.config/rofi/launcher.sh apps")          end, { description = "rofi apps",      group = "launcher" }),
  awful.key({ modkey },           "r", function() awful.spawn.with_shell("sh ~/.config/rofi/launcher.sh run")         end, { description = "rofi programs",  group = "launcher" }),
  awful.key({ modkey },           "w", function() awful.spawn.with_shell("sh ~/.config/rofi/launcher.sh window")         end, { description = "rofi windows",   group = "launcher" }),
  awful.key({ modkey },           "e", function() awful.spawn.with_shell("nemo")                                                    end, { description = "nemo",           group = "launcher" }),
  awful.key({ modkey, "Shift" }, "q",  function() awful.spawn.with_shell("sh ~/.config/rofi/powermenu.sh")         end, { description = "power options",  group = "awesome"  }),
  awful.key({ modkey },           "c", function() cw.toggle()                                                                       end, { description = "calendar popup", group = "launcher" }),
  awful.key({ modkey, "Control"}, "v", function() awful.spawn.with_shell("copyq menu")                                             end, { description = "copyq menu",     group = "launcher" }),
  awful.key({ modkey, "Shift" }, "s",  function() awful.spawn.with_shell("flameshot gui")                                           end, { description = "flameshot",      group = "launcher" }),
  awful.key({ modkey },           "p", function() awful.spawn.with_shell("scrcpy -S --power-off-on-close --window-x 10")            end, { description = "scrcpy",         group = "launcher" }),
  awful.key({ modkey },           "z", function()
    awful.spawn.with_shell("sh ~/.config/awesome/scripts/kpolybar.sh")
    awful.spawn.with_shell("sh ~/.config/awesome/scripts/spolybar.sh")
  end, { description = "respawn polybar", group = "launcher" }),

})
-- }}}

-- {{{ Tag number bindings
awful.keyboard.append_global_keybindings({
  awful.key {
    modifiers   = { modkey },
    keygroup    = "numrow",
    description = "only view tag",
    group       = "tag",
    on_press    = function(index)
      local screen = awful.screen.focused()
      local tag    = screen.tags[index]
      if tag then tag:view_only() end
    end,
  },
  awful.key {
    modifiers   = { modkey, "Shift" },
    keygroup    = "numrow",
    description = "move focused client to tag",
    group       = "tag",
    on_press    = function(index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
          tag:view_only()
        end
      end
    end,
  },
})
-- }}}

-- {{{ Client mouse bindings
client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    awful.button({}, 1, function(c)
      c:activate { context = "mouse_click" }
      close_all_menus()
      cw.close()
    end),
    awful.button({}, 3, function()
      close_all_menus()
      cw.close()
    end),
    awful.button({ modkey }, 1, function(c)
      c:activate { context = "mouse_click", action = "mouse_move" }
    end),
    awful.button({ modkey }, 3, function(c)
      c:activate { context = "mouse_click", action = "mouse_resize" }
    end),
  })
end)
-- }}}

-- {{{ Client keybindings
client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    awful.key({ modkey }, "f", function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end, { description = "toggle fullscreen", group = "client" }),

    awful.key({ modkey }, "q",     function(c) c:kill() end,
      { description = "close", group = "client" }),
    awful.key({ modkey }, "space", function(c) float(c) end,
      { description = "toggle floating", group = "client" }),
    awful.key({ modkey }, "t",     function(c) c.ontop = not c.ontop end,
      { description = "toggle on top", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
      { description = "move to master", group = "client" }),
    awful.key({ modkey }, "o",     function(c) c:move_to_screen() end,
      { description = "move to screen", group = "screen" }),
    awful.key({ modkey }, "n",     function(c) c.minimized = true end,
      { description = "minimize", group = "client" }),
    awful.key({ modkey }, "m",     function() maximize(client.focus) end,
      { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m", function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end, { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m", function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end, { description = "(un)maximize horizontally", group = "client" }),
  })
end)
-- }}}
