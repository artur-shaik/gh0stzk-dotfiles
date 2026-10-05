# This file launches the bar/s.
# ash: per-monitor module mode (full/min) via env PB_RIGHT + mode file
# ~/.cache/polybar-mode-<mon>. pid per monitor (~/.cache/polybar-<mon>.pid) for
# single-bar relaunch on toggle (bar-mode-toggle.sh). No arg = (re)launch all.
read -r RICE 2>/dev/null < "$HOME/.config/bspwm/.rice"
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"

# монитор для systray: eDP (ноут), а если eDP не активен (только внешний) —
# первый в списке. Иначе на конфигурации без eDP трей не вешается никуда и
# иконки пропадают. Один tray-монитор = нет гонки за _NET_SYSTEM_TRAY.
_monlist() { polybar --list-monitors | cut -d":" -f1; }
TRAY_MON=$(_monlist | grep -m1 '^eDP')
[ -z "$TRAY_MON" ] && TRAY_MON=$(_monlist | head -n1)

# есть ли батарея (десктоп/ноут без неё -> прячем всю battery-пилюлю с колпачками)
HAS_BAT=0
for _b in /sys/class/power_supply/BAT*; do [ -e "$_b" ] && HAS_BAT=1 && break; done

# right module sets (без tray-группы и хвоста power — добавляются ниже).
# left/center unchanged across modes.
RIGHT_FULL="vdict kblayer mpd2 tasks tactive gmail workrave loadavg docker memalert secscanalert secscanscan sep g3i network g3d sep g3i ping g3d updates2 keyboard sep g2i pulseaudio g2d sep g2i battery g2d bluetooth2 sep g2i usercard g2d sep g1i date g1d"
RIGHT_MIN="vdict kblayer mpd2 memalert secscanalert secscanscan sep g3i network g3d keyboard sep g2i pulseaudio g2d sep g2i battery g2d sep g1i date g1d"
# systray — на одном мониторе (TRAY_MON: eDP или первый). Иначе бары дерутся
# за _NET_SYSTEM_TRAY (гонка, иконки на случайном). traytoggle тоже только там.
TRAY_GROUP="sep ahi tray ahd traytoggle"

_launch_bar() {
    mon="$1"
    pidf="$HOME/.cache/polybar-$mon.pid"
    mode=$(cat "$HOME/.cache/polybar-mode-$mon" 2>/dev/null || echo full)
    [ "$mode" = min ] && right="$RIGHT_MIN" || right="$RIGHT_FULL"
    # нет батареи — вырезать battery-пилюлю целиком (колпачки + модуль),
    # схлопнуть осевший двойной sep
    [ "$HAS_BAT" = 0 ] && right=$(printf '%s' "$right" | sed -e 's/sep g2i battery g2d//' -e 's/  */ /g' -e 's/sep sep/sep/g' -e 's/^ *//;s/ *$//')
    if [ "$mon" = "$TRAY_MON" ]; then
        right="$right $TRAY_GROUP sep power"            # tray-монитор: с треем
    else
        right="$right sep power"                        # остальные: без трея
    fi
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
