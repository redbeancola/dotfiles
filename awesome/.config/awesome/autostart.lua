-- autostart.lua
-- Programs launched once when awesome starts.
-- Add idempotency guards in autorun.sh itself if needed.

local awful = require("awful")

local function spawn(cmd) awful.spawn.with_shell(cmd) end

spawn("sh ~/.config/awesome/scripts/autorun.sh")
spawn("kdeconnect-indicator")
spawn("feh --no-fehbg --bg-fill --randomize ~/Pictures/wallpapers/charlotte/upscaled/*")
spawn("picom --config ~/.config/picom/picom.conf")
spawn("fcitx5")
spawn("uxplay")
spawn("source ~/Terminal-discord-presence/tdrp-env/bin/activate && python3 ~/Terminal-discord-presence/UnixDRP.py")
spawn("sudo nethogs -t 2>/dev/null | tee /tmp/nethogs.txt > /dev/null &")
spawn("sudo killall conky; sleep 2 && conky -c ~/.config/conky/mocha.conf")
spawn("pkill polkit-gnome; pkill lxpolkit; lxpolkit &")
