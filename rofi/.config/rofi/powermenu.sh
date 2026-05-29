#!/usr/bin/env bash
# Adapted from rofi-collection by Aditya Shakya (@adi1090x)
# https://github.com/adi1090x/rofi

THEME="$HOME/.config/rofi/powermenu.rasi"
UPTIME="$(uptime -p | sed 's/up //')"
HOST="$(hostname)"

# Options
hibernate=''
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

rofi_cmd() {
    echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" \
        | rofi -dmenu \
               -p " $USER@$HOST" \
               -mesg " Uptime: $UPTIME" \
               -theme "$THEME"
}

confirm_cmd() {
    echo -e "$yes\n$no" \
        | rofi -dmenu \
               -p 'Confirmation' \
               -mesg 'Are you sure?' \
               -theme "$THEME" \
               -theme-str 'window {width: 350px;}' \
               -theme-str 'mainbox {orientation: vertical; children: ["message","listview"];}' \
               -theme-str 'listview {columns: 2; lines: 1;}' \
               -theme-str 'element-text {horizontal-align: 0.5;}' \
               -theme-str 'textbox {horizontal-align: 0.5;}'
}

run_cmd() {
    if [[ "$(confirm_cmd)" == "$yes" ]]; then
        case "$1" in
            --shutdown)  systemctl poweroff ;;
            --reboot)    systemctl reboot ;;
            --hibernate) systemctl hibernate ;;
            --suspend)   systemctl suspend ;;
            --logout)    loginctl terminate-user "$USER" ;;
            --lock)      betterlockscreen -l ;;
        esac
    fi
}

case "$(rofi_cmd)" in
    "$shutdown")  run_cmd --shutdown ;;
    "$reboot")    run_cmd --reboot ;;
    "$hibernate") run_cmd --hibernate ;;
    "$suspend")   run_cmd --suspend ;;
    "$logout")    run_cmd --logout ;;
    "$lock")      run_cmd --lock ;;

esac
