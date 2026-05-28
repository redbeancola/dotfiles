#!/bin/bash

# Use awesome-client to trigger the Lua code from Awesome WM
awesome-client << EOF
    close_all_menus()
    vpn_menu:show()
EOF
