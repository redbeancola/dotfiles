#!/bin/sh
prev=$(cat /tmp/ctxt_prev 2>/dev/null || echo 0)
curr=$(grep ctxt /proc/stat | awk '{print $2}')
echo $curr > /tmp/ctxt_prev
echo $((curr - prev))
