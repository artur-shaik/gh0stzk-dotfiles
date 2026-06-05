#!/bin/sh
# ash: pill-pipe.sh <color-name> <icon> — как pill-wrap, но для tail-потока
# (stdin, строка за строкой; gmail). Строка без цифр -> пилюля скрыта.
RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
col() { awk -v k="$1" '$1==k && $2=="=" {print $3; exit}' "$CFG"; }
ICON=$2

while IFS= read -r line; do
    case "$line" in
        *[0-9]*)
            C=$(col "$1"); BG=$(col bg)
            printf '%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B%s}%%{F%s} %s%s %%{F-}%%{B-}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B-}%%{F-}\n' \
                "$C" "$BG" "$C" "$BG" "$ICON" "$line" "$BG" "$C"
            ;;
        *) echo "" ;;
    esac
done
