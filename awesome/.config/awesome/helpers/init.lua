-- helpers/init.lua
-- all symbols here are intentionally global for calls via awesome-client
require("helpers.windows")
require("helpers.vpn")
require("helpers.updater")

local calendar_widget = require("helpers.calendar")

-- {{{ Calendar widget
cw = calendar_widget({
  theme        = "catppuccin",
  placement    = "top center",
  start_sunday = false,
  radius       = 8,
})
-- }}}

-- Expand this function for more menus added
function close_all_menus()
  if vpn_menu then vpn_menu:hide() end
  cw.close()
  close_update_popup()
end

function cal()       cw.toggle() end
function cal_close() cw.close()  end
