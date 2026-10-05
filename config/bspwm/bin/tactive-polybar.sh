#!/bin/sh
# ash: пилюля активной (started) задачи taskwarrior для polybar (tail, тик 1с).
# Проект + описание. Несколько активных -> циклим по одной каждые ROTATE сек.
# Нет активных -> пустая строка (пилюля скрыта). Текущую показываемую задачу
# пишем в STATE (uuid<TAB>project) — tactive-open.sh / tactive-stop.sh читают.

# polybar может стартовать без локали — иначе wc -m / cut -c режут по байтам
export LC_ALL="${LC_ALL:-C.UTF-8}"

ROTATE=4          # сек на одну задачу при нескольких активных
MAXLEN=42         # обрезка "проект: описание"
ICON="󰐊"
STATE="${XDG_RUNTIME_DIR:-/tmp}/tactive-current"

RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
col() { awk -v k="$1" '$1==k && $2=="=" {print $3; exit}' "$CFG"; }

pill() { # <color-role> <text>
    C=$(col "$1"); BG=$(col bg)
    printf ' %%{T4}%%{F%s}%%{B%s}%%{T-}%%{B%s}%%{F%s} %s %%{F-}%%{B-}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B-}%%{F-}\n' \
        "$C" "$BG" "$C" "$BG" "$2" "$BG" "$C"
}

tick=0
while :; do
    # активные задачи: строки "uuid<TAB>project<TAB>description"
    rows=$(task +ACTIVE export 2>/dev/null \
        | jq -r '.[] | "\(.uuid)\t\(.project // "")\t\(.description)"' 2>/dev/null)
    if [ -z "$rows" ]; then
        : > "$STATE" 2>/dev/null
        echo ""
        tick=0
        sleep 1
        continue
    fi

    n=$(printf '%s\n' "$rows" | wc -l)
    idx=$(( (tick / ROTATE) % n ))
    line=$(printf '%s\n' "$rows" | sed -n "$((idx + 1))p")

    uuid=$(printf '%s' "$line" | cut -f1)
    proj=$(printf '%s' "$line" | cut -f2)
    desc=$(printf '%s' "$line" | cut -f3)

    printf '%s\t%s\n' "$uuid" "$proj" > "$STATE" 2>/dev/null

    if [ -n "$proj" ]; then
        text="$proj: $desc"
    else
        text="$desc"
    fi
    # счётчик позиции при нескольких активных
    [ "$n" -gt 1 ] && text="$text [$((idx + 1))/$n]"
    # обрезка по MAXLEN символам (не байтам — кириллица). cut -c в UTF-8 locale
    # считает символы; хвост "…" только если реально обрезали
    if [ "$(printf '%s' "$text" | wc -m)" -gt "$MAXLEN" ]; then
        text="$(printf '%s' "$text" | cut -c1-"$MAXLEN")…"
    fi

    pill grad4 "$ICON $text"
    tick=$((tick + 1))
    sleep 1
done
