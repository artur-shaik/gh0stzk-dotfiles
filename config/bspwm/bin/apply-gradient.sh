#!/bin/sh
# ash: вписать grad1..5 (от wal-gradient) в РАБОЧИЙ config.ini текущего райса.
# Зовётся ПОСЛЕ wal-recolor (иначе recolor перекрашивает grad-hex по семантике).
export PATH="$HOME/.config/bspwm/bin:$PATH"
read -r RICE < "$HOME/.config/bspwm/.rice"
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
[ -f "$CFG" ] || exit 0
i=1
for g in $(wal-gradient.sh); do
    if grep -q "^grad$i = " "$CFG"; then
        sed -i "s/^grad$i = .*/grad$i = $g/" "$CFG"
    else
        sed -i "s/^\[color\]/[color]\ngrad$i = $g/" "$CFG"
    fi
    i=$((i+1))
done
