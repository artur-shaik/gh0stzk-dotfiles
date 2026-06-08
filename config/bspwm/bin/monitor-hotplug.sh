#!/bin/sh
# ash: реакция на hotplug мониторов — пере-раскладка + рестарт баров.
# Вынесено из bspwmrc, чтобы перезапускать без рестарта bspwm.
export PATH="$HOME/.config/bspwm/bin:$PATH"
LOG="$HOME/.cache/bspwm-hotplug.log"

snap() { for d in $(bspc query -D); do
    printf '%s@%s:%s ' "$(bspc query -D -d "$d" --names)" \
        "$(bspc query -M -m "$(bspc query -M -d "$d")" --names)" \
        "$(bspc query -N -d "$d" -n .window | wc -l)"
done; }

pkill -f 'bspc subscribe monitor' 2>/dev/null
bspc subscribe monitor | while read -r ev _; do
    case $ev in
        monitor_add|monitor_geometry|monitor_remove)
            printf '%s %s | BEFORE mons=[%s] desks: %s\n' "$(date +%T)" "$ev" \
                "$(bspc query -M --names | tr '\n' ',')" "$(snap)" >> "$LOG"
            MonitorSetup
            "$HOME/.local/bin/bar-restart"
            printf '%s %s | AFTER  mons=[%s] desks: %s\n' "$(date +%T)" "$ev" \
                "$(bspc query -M --names | tr '\n' ',')" "$(snap)" >> "$LOG"
            ;;
    esac
done &
