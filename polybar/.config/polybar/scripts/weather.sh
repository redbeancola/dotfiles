#!/bin/sh

sleep 5 
if 2>/dev/null 1>&2 ping -c 1 www.archlinux.org; then
  python3 ~/.config/polybar/scripts/weather.py
else
  echo ' '
fi
