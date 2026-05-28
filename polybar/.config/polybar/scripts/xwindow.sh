#!/bin/sh
result=$(awesome-client 'local awful = require("awful"); local focused_client = client.focus; local s = focused_client and focused_client.screen or awful.screen.focused(); local si = s and s.index or 0; return focused_client and "["..si.."] "..focused_client.name or "⸜(｡> v < )⸝♡"')
title=$(echo "$result" | awk -F'"' '{print $2}')
len=${#title}
if [ $len -gt 25 ]; then
    title="${title:0:25}..."
fi
pad=$(( (25 - ${#title}) / 2 ))
[ $pad -lt 0 ] && pad=0
printf "%*s%s%*s\n" $pad "" "$title" $pad ""
