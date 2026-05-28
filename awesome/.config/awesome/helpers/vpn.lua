-- helpers/vpn.lua
-- VPN menu exposed globally via awesome-client.
-- Depends on: vpn_loc_file, vpn_script  (config.lua)

local awful = require("awful")

local function vpn_connect(location)
  return ("echo '%s' | tee '%s' > /dev/null && %s %s"):format(
    location:upper(), vpn_loc_file, vpn_script, location:lower()
  )
end

local function vpn_disconnect()
  return ("echo 'HK' | tee '%s' > /dev/null && sudo killall openvpn"):format(vpn_loc_file)
end

vpn_menu = awful.menu({
  theme = { width = 200 },
  items = {
    { "JP",         function() awful.spawn.with_shell(vpn_connect("JP"))   end },
    { "TW",         function() awful.spawn.with_shell(vpn_connect("TW"))   end },
    { "disconnect", function() awful.spawn.with_shell(vpn_disconnect())    end },
  },
})
