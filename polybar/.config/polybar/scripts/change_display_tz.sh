#!/bin/bash
tz=$(cat ~/.config/polybar/data/tz)
if [ "$tz" -eq 0 ]; then
  echo 1 > ~/.config/polybar/data/tz
elif [ "$tz" -eq 1 ]; then
  echo 0 > ~/.config/polybar/data/tz
else
  echo 0 > ~/.config/polybar/data/tz  # reset corrupted value
fi
