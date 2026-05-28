#!/bin/bash
GEO=$(cat "$HOME/.config/polybar/data/vpn_loc")
if pgrep -x openvpn > /dev/null; then
  notify-send VPN "Disconnecting"
  echo "HK" | tee "$HOME/.config/polybar/data/vpn_loc" > /dev/null
  sudo killall openvpn
else
  echo "JP" | tee "$HOME/.config/polybar/data/vpn_loc" > /dev/null
  sudo /home/redbeancola/scripts/vpn.sh JP
fi
