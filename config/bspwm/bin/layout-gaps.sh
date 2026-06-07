#!/bin/sh
# ash: вертикальные гапы по layout'у — tiled: top/bottom padding, monocle: впритык.
# Демон: подписка на смену layout; init-проход по всем десктопам.
VGAP=20

set_pad() {
    # $1 = desktop id, $2 = layout
    if [ "$2" = "monocle" ]; then
        bspc config -d "$1" top_padding 0
        bspc config -d "$1" bottom_padding 0
    else
        bspc config -d "$1" top_padding "$VGAP"
        bspc config -d "$1" bottom_padding "$VGAP"
    fi
}

# init: текущие layout'ы всех десктопов
for d in $(bspc query -D); do
    set_pad "$d" "$(bspc query -T -d "$d" | jq -r .layout)"
done

bspc subscribe desktop_layout | while read -r _ _ desktop layout; do
    set_pad "$desktop" "$layout"
done
