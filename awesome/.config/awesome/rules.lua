-- rules.lua
-- Client placement and property rules.

local awful = require("awful")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()

  -- {{{ Global defaults
  ruled.client.append_rule {
    id         = "global",
    rule       = {},
    properties = {
      focus     = awful.client.focus.filter,
      raise     = true,
      screen    = awful.screen.focused,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    }
  }
  -- }}}

  -- {{{ Floating clients
  ruled.client.append_rule {
    id       = "floating",
    rule_any = {
      instance = { "copyq", "pinentry" },
      class    = {
        "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
        "Wpa_gui", "veromix", "xtightvncviewer", "pavucontrol",
      },
      name = { "Event Tester" },
      role = { "AlarmWindow", "ConfigManager", "pop-up" },
    },
    properties = { floating = true }
  }
  -- }}}

  -- {{{ No titlebars
  ruled.client.append_rule {
    id       = "titlebars",
    rule_any = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = false }
  }
  -- }}}

  -- {{{ App-specific placement

  ruled.client.append_rule {
    rule       = { instance = "chromium" },
    properties = { screen = 1, tag = "4", floating = true }
  }

  ruled.client.append_rule {
    rule       = { class = "steam" },
    properties = { screen = 2, floating = true }
  }
  ruled.client.append_rule {
    rule       = { name = "^Steam$" },
    properties = { screen = 2, floating = false }
  }

  ruled.client.append_rule {
    rule       = { class = "discord" },
    properties = { screen = 2, tag = "1" }
  }
  ruled.client.append_rule {
    rule       = { instance = "discord-screenaudio" },
    properties = { screen = 2 }
  }

  ruled.client.append_rule {
    rule_any   = { instance = { "youtube music" } },
    properties = { screen = 1, tag = "3" }
  }
  ruled.client.append_rule {
    rule_any   = { class = { "thunderbird" } },
    properties = { screen = 1, tag = "3" }
  }

  ruled.client.append_rule {
    rule       = { instance = "vscodium" },
    properties = { screen = 1, tag = "4" }
  }

  ruled.client.append_rule {
    rule       = { instance = "dolphin-emu" },
    properties = { floating = true }
  }
  ruled.client.append_rule {
    rule       = { instance = "Windscribe" },
    properties = { floating = true }
  }
  ruled.client.append_rule {
    rule       = { instance = "feh" },
    properties = { floating = true }
  }
  ruled.client.append_rule {
    rule       = { instance = "scrcpy" },
    properties = { floating = true }
  }

  ruled.client.append_rule {
    rule       = { instance = "polybar" },
    properties = { border_width = 0, focusable = false }
  }

  -- {{{ System Update Popup Terminal
  ruled.client.append_rule {
    id         = "update_popup_terminal",
    rule       = { class = "update-terminal" },
    properties = {
      floating     = true,
      ontop        = true,
      sticky       = true,       -- Visible across all workspaces/tags
      above        = true,
      skip_taskbar = true,       -- Keeps it clean from panels
      border_width = 2,
      border_color = "#b4befe",  -- Catppuccin Lavender matching your popup
      
      -- Set explicit dimensions to resemble a UI element
      width        = 600,
      height       = 400,

      placement    = function(c)
        -- Centers the window on the mouse, but shifts it down by 100 pixels
        awful.placement.under_mouse(c, { offset = { x = 0, y = 250 } })
        awful.placement.no_offscreen(c)
      end
    }
  }

  -- }}}

end)
