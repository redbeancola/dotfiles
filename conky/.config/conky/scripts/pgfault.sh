#!/bin/sh
prev_maj=$(cat /tmp/pgmaj_prev 2>/dev/null || echo 0)
prev_min=$(cat /tmp/pgmin_prev 2>/dev/null || echo 0)
curr_maj=$(grep pgmajfault /proc/vmstat | awk '{print $2}')
curr_min=$(grep pgfault /proc/vmstat | awk '{print $2}')
echo $curr_maj > /tmp/pgmaj_prev
echo $curr_min > /tmp/pgmin_prev
echo "$((curr_maj - prev_maj)) - $((curr_min - prev_min))"
