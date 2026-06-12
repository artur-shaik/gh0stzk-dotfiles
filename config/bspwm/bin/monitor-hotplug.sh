#!/bin/sh
# ash: реакция на hotplug — с ДЕБАУНСОМ. monitor_geometry сыпется пачкой;
# без дебаунса параллельные MonitorSetup+bar-restart дрались и теряли окна.
# Окна при отключении мигрирует сам bspwm (remove_unplugged_monitors=true).
export PATH="$HOME/.config/bspwm/bin:$PATH"
LOG="$HOME/.cache/bspwm-hotplug.log"
PIDF=/tmp/.hotplug-debounce.pid

apply() {
    sleep 1.2   # переждать пачку событий
    # ГАРД (2026-06-11): транзиентный DPMS/лок (смена темы под xsecurelock)
    # может дать 0 connected / 0 мониторов. Тогда MonitorSetup'овский цикл
    # `xrandr --output <disconnected> --off` гасит ВСЕ выходы -> bspwm в ноль
    # мониторов -> сессия коллапсирует, X выходит (падал именно так).
    # На вырожденном состоянии — пропустить; bspwm восстановит при пробуждении.
    conn=$(xrandr 2>/dev/null | grep -c ' connected')
    mons=$(bspc query -M --names 2>/dev/null | grep -c .)
    printf '%s apply | conn=%s mons=%s\n' "$(date +%T)" "$conn" "$mons" >> "$LOG"
    if [ "${conn:-0}" -eq 0 ] || [ "${mons:-0}" -eq 0 ]; then
        printf '%s SKIP transient (DPMS/lock, xrandr не трогаем)\n' "$(date +%T)" >> "$LOG"
        return
    fi
    MonitorSetup
    "$HOME/.local/bin/bar-restart"
}

pkill -f 'bspc subscribe monitor' 2>/dev/null
bspc subscribe monitor | while read -r ev _; do
    case $ev in
        monitor_add|monitor_geometry|monitor_remove)
            [ -f "$PIDF" ] && kill "$(cat "$PIDF")" 2>/dev/null
            apply & echo $! > "$PIDF"
            ;;
    esac
done
