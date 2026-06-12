#!/bin/sh
# ash: title с иконкой по layout/state текущего десктопа/окна.
# tiled 󰕰 | monocle 󰖯 | floating-окно в фокусе 󰖲. Реактивно (bspc subscribe).
export PATH="$HOME/.config/bspwm/bin:$PATH"

# лимит длины — от ширины монитора этого бара (env MONITOR от Bar.bash):
# узкий экран — режем коротко, широкий — даём заголовку дышать.
# ширину берём из кэша MonitorSetup (/tmp/.mon-width.$MONITOR), не xrandr
# (тот в поллере = EDID-спам). Эмпирика: справа большой блок модулей,
# центр пуст — резерв ~1000px, ~18px/символ; clamp 30..70.
w=$(cat "/tmp/.mon-width.${MONITOR:-eDP-1}" 2>/dev/null)
tlim=$(( (${w:-1920} - 1000) / 18 ))
[ "$tlim" -lt 30 ] && tlim=30
[ "$tlim" -gt 70 ] && tlim=70

# глиф eye-off (U+F0209, MDI; есть в JBMono NF) — octal-printf, т.к. raw UTF-8
# в файле теряется при Write. Dim-цвет «тусклости» — из палитры бара (blackb).
EYE=$(printf '\363\260\210\211')
# глиф pin (U+F0403 md-pin) — индикатор sticky-окна (super+e). octal-printf.
PIN=$(printf '\363\260\220\203')
RICE=$(cat "$HOME/.config/bspwm/.rice" 2>/dev/null)
dim=$(awk '$1=="blackb" && $2=="="{print $3; exit}' "$HOME/.config/bspwm/rices/$RICE/config.ini" 2>/dev/null)
dim=${dim:-#666666}

draw() {
    foc=$(bspc query -N -d focused -n .focused.window 2>/dev/null)
    if [ -n "$foc" ] && bspc query -N -n "$foc.floating" >/dev/null 2>&1; then
        icon='󰖲'
    elif [ "$(bspc query -T -d focused 2>/dev/null | jq -r .layout)" = "monocle" ]; then
        icon='󰖯'
        # >1 окна в monocle — мелкий superscript-счётчик
        n=$(bspc query -N -d focused -n .window | wc -l)
        [ "$n" -gt 1 ] && icon="${icon}×${n}"
    else
        icon='󰕰'
    fi
    if [ -n "$foc" ]; then
        title=$(xdotool getwindowname "$foc" 2>/dev/null | cut -c1-$tlim)
    else
        title='openSUSE'
    fi
    # sticky-окно в фокусе (super+e) → pin рядом с layout-иконкой
    pin=""
    [ -n "$foc" ] && bspc query -N -n "$foc.sticky" >/dev/null 2>&1 && pin=" $PIN"
    # hidden-окна текущего десктопа (super+u прячет, копятся незаметно) —
    # глаз-офф + счёт ПОСЛЕ титла, тускло (%{F} dim). >0 → показать.
    hid=$(bspc query -N -d focused -n .hidden.window 2>/dev/null | wc -l)
    if [ "$hid" -gt 0 ]; then
        printf '%s%s  %s  %%{F%s}%s %s%%{F-}\n' "$icon" "$pin" "$title" "$dim" "$EYE" "$hid"
    else
        printf '%s%s  %s\n' "$icon" "$pin" "$title"
    fi
}

draw
bspc subscribe node_focus node_state node_flag desktop_layout desktop_focus | while read -r _; do
    draw
done
