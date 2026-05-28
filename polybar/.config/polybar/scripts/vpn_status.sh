#!/bin/bash

VPN_STATUS=$(pgrep -x openvpn)

GEO=$(cat /home/redbeancola/.config/polybar/data/vpn_loc)

if [ -n "$VPN_STATUS" ]; then
    echo "  $GEO"
else
    echo "睊 $GEO"
fi
