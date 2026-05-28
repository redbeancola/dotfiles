#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrandr --output HDMI-0 --off \
       --output DP-0 --primary --mode 3840x2160 --rate 144 --pos 2592x0 --rotate normal \
       --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-5 --off \
       --output HDMI-1-2 --mode 1920x1080 --pos 0x0 --scale 1.35x1.35 --rotate normal \
       --output DP-1-1 --off --output HDMI-1-2 --off 
exec awesome


