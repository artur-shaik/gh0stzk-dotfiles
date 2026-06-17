#!/bin/sh
# ash: pill-wrap.sh <color-name> <icon> <hide-regex> <command...>
# Рисует polybar-пилюлю вокруг вывода команды. Пустой вывод или совпадение
# с hide-regex -> пустая строка (модуль исчезает вместе с колпачками,
# т.к. колпачки здесь же, а не отдельными модулями).
RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
col() { awk -v k="$1" '$1==k && $2=="=" {print $3; exit}' "$CFG"; }

# ash: $1 = имя роли из [color] ИЛИ прямой #hex (для семантичных цветов вроде
# алого алерта угрозы, что не должен зависеть от wal-палитры).
case "$1" in
    \#*) C="$1" ;;
    *)   C=$(col "$1") ;;
esac
BG=$(col bg)
ICON=$2; RE=$3
shift 3

out=$(eval "$@" 2>/dev/null)
# скрытие: ЯВНАЯ пустая строка — на тихий exit без вывода polybar
# не обновляет label и пилюля «зависает» с прошлым содержимым
[ -z "$out" ] && { echo ""; exit 0; }
if [ -n "$RE" ] && printf '%s' "$out" | grep -Eq "$RE"; then echo ""; exit 0; fi

printf ' %%{T4}%%{F%s}%%{B%s}%%{T-}%%{B%s}%%{F%s} %s%s %%{F-}%%{B-}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B-}%%{F-}\n' \
    "$C" "$BG" "$C" "$BG" "$ICON" "$out" "$BG" "$C"
