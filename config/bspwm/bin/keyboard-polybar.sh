#!/bin/sh
# ash: раскладка для polybar. ru -> красная пилюля (алерт как у workrave),
# us/en -> grad3 (дефолт градиента). Реактивно: xkb-switch -W (watch).
RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
col() { awk -v k="$1" '$1==k && $2=="=" {print $3; exit}' "$CFG"; }
ICON="󰌌"

draw() {
    lay=$1
    case "$lay" in
        ru) C="#d54e53" ;;          # фикс-красный, как просрочка workrave
        *)  C=$(col grad3) ;;       # дефолт градиента
    esac
    BG=$(col bg)
    # пилюля: колпачок + содержимое + колпачок (цвет C, текст BG)
    printf ' %%{T4}%%{F%s}%%{B%s}%%{T-}%%{B%s}%%{F%s} %s %s %%{F-}%%{B-}%%{T4}%%{F%s}%%{B%s}%%{T-}%%{B-}%%{F-}\n' \
        "$C" "$BG" "$C" "$BG" "$ICON" "$lay" "$BG" "$C"
}

draw "$(xkb-switch 2>/dev/null)"
xkb-switch -W 2>/dev/null | while read -r lay; do
    draw "$lay"
done
