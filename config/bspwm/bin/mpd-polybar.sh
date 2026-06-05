#!/bin/sh
# ash: mpd для polybar. "[artist - ]title" — артист только если задан
# (скобки mpc = условный вывод), иконка play/pause.
HOST="${MPD_HOST_OVERRIDE:-$(cat "$HOME/.mpd_host" 2>/dev/null || echo localhost)}"
PORT="$(cat "$HOME/.mpd_port" 2>/dev/null || echo 6600)"

cur=$(mpc -h "$HOST" -p "$PORT" current -f '[[%artist% - ]%title%]' 2>/dev/null | cut -c1-40)
[ -z "$cur" ] && exit 0

state=$(mpc -h "$HOST" -p "$PORT" status 2>/dev/null | sed -n '2s/^\[\([a-z]*\)\].*/\1/p')
if [ "$state" = "playing" ]; then
    icon=""
else
    icon=""
fi
printf '%s %s\n' "$icon" "$cur"
