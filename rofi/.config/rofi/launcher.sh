#!/usr/bin/env bash

THEME="$HOME/.config/rofi/theme.rasi"

case "$1" in
    apps)   rofi -show drun   -theme "$THEME" -markup-rows ;;
    run)    rofi -show run    -theme "$THEME" ;;
    window) rofi -show window -theme "$THEME" ;;
    *)      echo "Usage: $0 {apps|run|window}" ;;
esac
