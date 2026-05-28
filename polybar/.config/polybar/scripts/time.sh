#!/bin/bash
tz=$(cat ~/.config/polybar/data/tz)
if [ "$tz" -eq 1 ]; then
  TZ="/usr/share/zoneinfo/Japan" date "+%H:%M:%S JP"
else
  TZ="/usr/share/zoneinfo/Hongkong" date "+%H:%M:%S HK"
fi
