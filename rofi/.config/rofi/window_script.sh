#!/bin/sh
result=$(awesome-client '
    local client = client
    local table = table
    local ipairs = ipairs
    
    -- Get all clients and copy to a sortable table
    local clients = {}
    for _, c in ipairs(client.get()) do
        table.insert(clients, c)
    end
    
    -- Sort by screen index, then tag index, then client name
    table.sort(clients, function(a, b)
        local a_screen = a.screen and a.screen.index or 0
        local b_screen = b.screen and b.screen.index or 0
        if a_screen ~= b_screen then return a_screen < b_screen end
        
        local a_tag = a.first_tag and a.first_tag.index or 0
        local b_tag = b.first_tag and b.first_tag.index or 0
        if a_tag ~= b_tag then return a_tag < b_tag end
        
        return (a.name or "") < (b.name or "")
    end)
    
    -- Format the output string
    local result = ""
    for _, c in ipairs(clients) do
        local si = c.screen and c.screen.index or 0
        local tag = c.first_tag and c.first_tag.index or 0
        local minimized = c.minimized and "1" or "0"
        result = result .. "["..si.."] · {"..tag.."} ".. (c.class or "?") .." · "..(c.name or "?").."|||"..(c.class or "?").."|||"..minimized.."NEWLINE"
    end
    return result
' | awk -F'"' '{print $2}')

if [ -n "$1" ]; then
    title=$(echo "$1" | sed 's/\[.\] · {.} //' | awk -F' · ' '{print $2}')
    if [ "$ROFI_RETV" = "10" ]; then
        awesome-client "for _, c in ipairs(client.get()) do if c.name == '$title' then c:kill() end end"
    else
        awesome-client "local awful = require('awful'); local old = mouse.coords(); for _, c in ipairs(client.get()) do if c.name == '$title' then c:jump_to(); mouse.coords(old) end end"
    fi
    exit 0
fi

echo "$result" | sed 's/NEWLINE/\n/g' | grep '|||' | grep -v 'Polybar' | awk -F'[|][|][|]' '{
    if ($3 == "1")
        printf "~ %s\0icon\x1f%s\n", $1, tolower($2)
    else
        printf "%s\0icon\x1f%s\n", $1, tolower($2)
}'
