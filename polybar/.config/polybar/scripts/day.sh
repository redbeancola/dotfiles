# ~/.config/polybar/scripts/day.sh
#!/bin/bash

# Get weekday number (1=Monday, 7=Sunday)
day=$(date +%u)
cute="⸜(｡> v < )⸝♡"

# Map number to Japanese weekday symbol
case $day in
  1) echo "月曜日" $cute ;;  # Monday
  2) echo "火曜日" $cute ;;  # Tuesday
  3) echo "水曜日" $cute ;;  # Wednesday
  4) echo "木曜日" $cute ;;  # Thursday
  5) echo "金曜日" $cute ;;  # Friday
  6) echo "土曜日" $cute ;;  # Saturday
  7) echo "日曜日" $cute ;;  # Sunday
esac
