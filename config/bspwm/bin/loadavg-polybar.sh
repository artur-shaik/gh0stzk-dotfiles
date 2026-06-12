#!/bin/sh
# ash: loadavg-пилюля. load1 (1-мин средняя) > 6 -> алый алерт (#d54e53,
# как просрочка workrave/ru-раскладка), иначе grad4. Сам рисует пилюлю
# (колпачки+фон) — статичный format-background не умеет условный цвет.
# Клик -> btop. interval-скрипт (не tail).
RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
col() { awk -v k="$1" '$1==k && $2=="=" {print $3; exit}' "$CFG"; }
ICON="󰊚"

load1=$(awk '{print $1}' /proc/loadavg)
if awk -v l="$load1" 'BEGIN{exit !(l+0 > 6)}'; then
    C="#d54e53"          # алерт: нагрузка > 6
else
    C=$(col grad4)       # норма: цвет градиента
fi
BG=$(col bg)
CLICK="alacritty --class Btop -e btop &"

# ведущий пробел + клик-зона вокруг всей пилюли: колпачок + 󰊚 load1 + колпачок
printf ' %%{A1:%s:}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B%s}%%{F%s} %s %s %%{F-}%%{B-}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B-}%%{F-}%%{A}\n' \
    "$CLICK" "$C" "$BG" "$C" "$BG" "$ICON" "$load1" "$BG" "$C"
