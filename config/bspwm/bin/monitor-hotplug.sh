#!/bin/sh
# ash: реакция на hotplug — с ДЕБАУНСОМ. monitor_geometry сыпется пачкой;
# без дебаунса параллельные MonitorSetup+bar-restart дрались и теряли окна.
# Окна при отключении мигрирует сам bspwm (remove_unplugged_monitors=true).
export PATH="$HOME/.config/bspwm/bin:$PATH"
LOG="$HOME/.cache/bspwm-hotplug.log"
PIDF=/tmp/.hotplug-debounce.pid

apply() {
    sleep 1.2   # переждать пачку событий
    printf '%s apply | mons=[%s]\n' "$(date +%T)" "$(bspc query -M --names | tr '\n' ',')" >> "$LOG"
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
