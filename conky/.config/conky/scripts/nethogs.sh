#!/bin/sh
tail -n 200 /tmp/nethogs.txt > /tmp/nethogs.tmp
cp /tmp/nethogs.tmp /tmp/nethogs.txt

awk -f ~/.config/conky/scripts/nethogs.awk /tmp/nethogs.txt | sort -rn | head -n 10 | awk -F'\t' '{
    if ($2 ~ /^\/proc/) {
        split($2, arr, "/")
        cmd = "readlink /proc/" arr[5] "/exe 2>/dev/null"
        cmd | getline exepath
        close(cmd)
        n = split(exepath, earr, "/")
        name = earr[n]
        if (name == "") name = "pid-" arr[5]
    } else if ($2 ~ /^\//) {
        n = split($2, arr, "/")
        name = arr[n-2]
        # if name looks like a PID (all digits), go one level up
        if (name ~ /^[0-9]+$/) name = arr[n-3]
    } else {
        split($2, arr, "/")
        name = arr[1]
    }
    if (length(name) > 12) name = substr(name, 1, 12)
      tx = ($3 + 0) * 1000
      rx = ($4 + 0) * 1000
      if (tx >= 1000000) txs = sprintf("%.1f MB/s", tx/1000000)
      else if (tx >= 1000) txs = sprintf("%.1f KB/s", tx/1000)
      else txs = sprintf("%.0f  B/s", tx)
      if (rx >= 1000000) rxs = sprintf("%.1f MB/s", rx/1000000)
      else if (rx >= 1000) rxs = sprintf("%.1f KB/s", rx/1000)
    else rxs = sprintf("%.0f  B/s", rx)
  printf "%-12s %9s↑ %9s↓\n", name, txs, rxs
}'
