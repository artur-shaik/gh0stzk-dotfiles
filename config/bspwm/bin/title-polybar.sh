#!/bin/sh
# ash: title с иконкой по layout/state текущего десктопа/окна.
# tiled 󰕰 | monocle 󰊓 | floating-окно в фокусе 󰖲. Реактивно (bspc subscribe).
export PATH="$HOME/.config/bspwm/bin:$PATH"

draw() {
    foc=$(bspc query -N -d focused -n .focused.window 2>/dev/null)
    if [ -n "$foc" ] && bspc query -N -n "$foc.floating" >/dev/null 2>&1; then
        icon='󰖲'
    elif [ "$(bspc query -T -d focused 2>/dev/null | jq -r .layout)" = "monocle" ]; then
        icon='󰊓'
    else
        icon='󰕰'
    fi
    if [ -n "$foc" ]; then
        title=$(xdotool getwindowname "$foc" 2>/dev/null | cut -c1-30)
    else
        title='openSUSE'
    fi
    printf '%s  %s\n' "$icon" "$title"
}

draw
bspc subscribe node_focus node_state node_flag desktop_layout desktop_focus | while read -r _; do
    draw
done
