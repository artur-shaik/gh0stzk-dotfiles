#!/bin/sh
# ash: переустановка раскладки при hotplug клавиатуры — X сбрасывает
# layout на дефолт когда USB-клава (Corne) переподключается.
LAYOUT="setxkbmap -layout us,ru -option grp:alt_space_toggle,grp_led:caps,ctrl:nocaps"
$LAYOUT
PIDF=/tmp/.kbd-layout-debounce.pid

udevadm monitor --subsystem-match=input --udev 2>/dev/null | while read -r line; do
    case $line in
        *add*|*remove*)
            [ -f "$PIDF" ] && kill "$(cat "$PIDF")" 2>/dev/null
            (sleep 1; $LAYOUT) & echo $! > "$PIDF"
            ;;
    esac
done
