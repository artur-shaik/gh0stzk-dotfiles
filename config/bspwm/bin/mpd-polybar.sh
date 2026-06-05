#!/bin/sh
# ash: mpd для polybar. "[artist - ]title" — артист только если задан.
# Хост выбирает обёртка bspwm/bin/mpc (активный: remote или localhost).
export PATH="$HOME/.config/bspwm/bin:$PATH"

cur=$(mpc current -f '[[%artist% - ]%title%]' 2>/dev/null | cut -c1-70)
[ -z "$cur" ] && exit 0

state=$(mpc status 2>/dev/null | sed -n '2s/^\[\([a-z]*\)\].*/\1/p')
if [ "$state" = "playing" ]; then
    icon="󰐊"
else
    icon="󰏤"
fi
printf '%s %s\n' "$icon" "$cur"
