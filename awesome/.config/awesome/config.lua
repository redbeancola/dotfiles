-- Global constants used throughout the config and by external scripts.
-- NOTE: these are intentionally global so awful.spawn commands and
-- awesome-client calls from polybar scripts can reference them.

local home = os.getenv("HOME")

-- {{{ Applications
terminal   = "kitty"
editor     = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey     = "Mod4"
-- }}}

-- {{{ Tags / screens
tag_names        = { "1", "2", "3", "4", "5" }
screen_primary   = 1
screen_secondary = 2
-- Tag labels used in rules
tag_chat         = "1"
tag_media        = "3"
tag_browser      = "4"
-- }}}

-- {{{ Window behaviour
float_width  = 1000
float_height = 550
-- }}}

-- {{{ Cursor
cursor_path = "/usr/share/icons/catppuccin-macchiato-lavender-cursors/cursors/left_ptr"
cursor_size = 24
-- }}}

-- {{{ VPN
vpn_loc_file = home .. "/.config/polybar/vpn_loc.txt"
vpn_script   = "sudo " .. home .. "/scripts/vpn.sh"
-- }}}

-- {{{ Paths
path_wallpapers  = home .. "/Pictures/wallpapers/charlotte/upscaled/*"
path_picom       = home .. "/.config/picom/picom.conf"
path_conky       = home .. "/.config/conky/mocha.conf"
path_nethogs_log = "/tmp/nethogs.txt"
path_discord_rpc = home .. "/Terminal-discord-presence"
-- }}}

-- {{{ Notifications
notif_timeout     = 4
notif_spacing     = 16
notif_corner_r    = 5    -- rounded_rect radius (px)
notif_icon_size   = 115  -- dpi
notif_width       = 300  -- dpi
notif_height_max  = 200  -- dpi
notif_height_min  = 130  -- dpi
notif_padding     = 15   -- dpi
notif_icon_gap    = 25   -- dpi  (gap between icon and message)
notif_act_spacing = 20   -- dpi  (between action buttons)
notif_act_margin  = 3    -- dpi  (left/right margin on action labels)
notif_font_title  = "Product Sans Bold 12"
notif_font_msg    = "Product Sans 12"
notif_font_action = "Product Sans 10"
-- }}}

-- {{{ Updater
updater_timeout       = 600
updater_forced_width  = 600
updater_maximum_width = 600
updater_minimum_width = 600
updater_forced_height = 180
updater_popup_x       = 5550
updater_popup_y       = 60
updater_polkit_x      = 5700
updater_polkit_y      = 170
-- }}}

-- {{{ Garbage collection
gc_pause    = 110
gc_stepmul  = 1000
gc_interval = 5
-- }}}
