/^Refreshing:/ { next }
{
    path = $1
    if (path ~ /\/[0-9]+\/[0-9]+$/) {
        tx = $2 + 0
        rx = $3 + 0
        if (tx > max_tx[path]) max_tx[path] = tx
        if (rx > max_rx[path]) max_rx[path] = rx
        procs[path] = 1
    }
}
END {
    for (path in procs)
        print (max_tx[path] + max_rx[path]) "\t" path "\t" max_tx[path] "\t" max_rx[path]
}
