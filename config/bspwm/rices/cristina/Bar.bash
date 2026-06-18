# This file launches the bar/s.
# ash: per-monitor module mode (full/min) via env PB_RIGHT + mode file
# ~/.cache/polybar-mode-<mon>. pid per monitor (~/.cache/polybar-<mon>.pid) for
# single-bar relaunch on toggle (bar-mode-toggle.sh). No arg = (re)launch all.
read -r RICE 2>/dev/null < "$HOME/.config/bspwm/.rice"
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"

# right module sets (left/center unchanged across modes)
RIGHT_FULL="mpd2 tasks gmail workrave loadavg docker secscanalert secscanscan sep g3i network g3d sep g3i ping g3d updates2 keyboard sep g2i pulseaudio g2d sep g2i battery g2d bluetooth2 sep g2i usercard g2d sep g1i date g1d sep ahi tray ahd traytoggle sep power"
RIGHT_MIN="secscanalert secscanscan sep g3i network g3d keyboard sep g2i pulseaudio g2d sep g2i battery g2d sep g1i date g1d sep ahi tray ahd traytoggle sep power"

_launch_bar() {
    mon="$1"
    pidf="$HOME/.cache/polybar-$mon.pid"
    mode=$(cat "$HOME/.cache/polybar-mode-$mon" 2>/dev/null || echo full)
    [ "$mode" = min ] && right="$RIGHT_MIN" || right="$RIGHT_FULL"
    # kill this monitor's prior bar (toggle relaunch); wait for slow systray die
    if [ -f "$pidf" ]; then
        oldpid=$(cat "$pidf")
        kill "$oldpid" 2>/dev/null
        i=0
        while kill -0 "$oldpid" 2>/dev/null; do
            i=$((i + 1))
            [ "$i" -ge 20 ] && { kill -9 "$oldpid" 2>/dev/null; break; }
            sleep 0.15
        done
    fi
    MONITOR="$mon" PB_RIGHT="$right" polybar -q cristina-bar -c "$CFG" &
    echo $! > "$pidf"
}

if [ -n "$1" ]; then
    _launch_bar "$1"
else
    for mon in $(polybar --list-monitors | cut -d":" -f1); do _launch_bar "$mon"; done
fi
