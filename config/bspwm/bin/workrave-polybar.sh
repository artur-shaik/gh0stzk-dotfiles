#!/bin/sh
# ash: workrave-пилюля для polybar (tail-режим, тик 1с).
# Состояния: countdown до rest break (purple, 󰅶; quiet -> 󰂛),
# идёт перерыв (green, 󰏤, отсчёт перерыва), suspended (blue, 󰒲 zzz).
# Нет workrave -> пустая строка, пилюля скрыта.
# `workrave-polybar.sh toggle` — переключить normal<->suspended (click-right).
# `workrave-polybar.sh break`  — форсировать перерыв на отдых (click-left).
# `workrave-polybar.sh open`   — окно workrave на ТЕКУЩИЙ десктоп + фокус (click-middle);
# голый OpenMain открывает окно на десктопе, где оно жило — юзер его не видит.

WR_DEST=org.workrave.Workrave
WR_CORE=/org/workrave/Workrave/Core
WR_IFACE=org.workrave.CoreInterface

core() { busctl --user call "$WR_DEST" "$WR_CORE" "$WR_IFACE" "$@" 2>/dev/null; }
# i 123 / s "foo" -> голое значение
val() { core "$@" | awk '{gsub(/"/,"",$2); print $2}'; }

if [ "$1" = "toggle" ]; then
    m=$(val GetOperationMode)
    [ "$m" = "suspended" ] && n=normal || n=suspended
    core SetOperationMode s "$n"
    exit 0
fi

if [ "$1" = "break" ]; then
    busctl --user call "$WR_DEST" /org/workrave/Workrave/UI \
        org.workrave.ControlInterface RestBreak 2>/dev/null
    exit 0
fi

if [ "$1" = "open" ]; then
    busctl --user call "$WR_DEST" /org/workrave/Workrave/UI \
        org.workrave.ControlInterface OpenMain 2>/dev/null
    sleep 0.3
    # xdotool search не годится: видит 4 workrave-окна (трей/брейк, unmapped);
    # wmctrl лижет только managed-окна
    wid=$(wmctrl -lx 2>/dev/null | awk '/workrave\.Workrave/{print $1; exit}')
    [ -n "$wid" ] || exit 0
    bspc node "$wid" -d focused 2>/dev/null
    bspc node "$wid" -f
    exit 0
fi

RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
col() { awk -v k="$1" '$1==k && $2=="=" {print $3; exit}' "$CFG"; }

pill() { # <color-name> <text>
    C=$(col "$1"); BG=$(col bg)
    printf ' %%{T4}%%{F%s}%%{B%s}%%{T-}%%{B%s}%%{F%s} %s %%{F-}%%{B-}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B-}%%{F-}\n' \
        "$C" "$BG" "$C" "$BG" "$2" "$BG" "$C"
}

mmss() { s=$1; [ "$s" -lt 0 ] && s=0; printf '%d:%02d' $((s / 60)) $((s % 60)); }

# длительности перерывов из конфига workrave (меняются редко — читаем раз)
REST_LEN=$(busctl --user call "$WR_DEST" "$WR_CORE" org.workrave.ConfigInterface \
    GetInt s "timers/rest_break/auto_reset" 2>/dev/null | awk '{print $2}')
MICRO_LEN=$(busctl --user call "$WR_DEST" "$WR_CORE" org.workrave.ConfigInterface \
    GetInt s "timers/micro_pause/auto_reset" 2>/dev/null | awk '{print $2}')

while :; do
    mode=$(val GetOperationMode)
    if [ -z "$mode" ]; then
        # workrave не бежит: явная пустая строка, иначе polybar заморозит label
        echo ""
    elif [ "$mode" = "suspended" ]; then
        pill blue "󰒲 zzz"
    elif [ "$(val GetBreakState s restbreak)" = "active" ]; then
        left=$(( ${REST_LEN:-0} - $(val GetTimerIdle s restbreak) ))
        pill green "󰏤 $(mmss $left)"
    elif [ "$(val GetBreakState s microbreak)" = "active" ]; then
        left=$(( ${MICRO_LEN:-0} - $(val GetTimerIdle s microbreak) ))
        pill green "󰏤 $(mmss $left)"
    else
        [ "$mode" = "quiet" ] && icon="󰂛" || icon="󰅶"
        left=$(val GetTimerRemaining s restbreak)
        over=$(val GetTimerOverdue s restbreak)
        if [ "${left:-0}" -le 0 ] && [ "${over:-0}" -gt 0 ]; then
            # перерыв просрочен (отложен): Remaining замирает на 0, растёт Overdue
            pill red "$icon +$(mmss "$over")"
        else
            pill purple "$icon $(mmss "$left")"
        fi
    fi
    sleep 1
done
