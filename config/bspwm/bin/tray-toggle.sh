#!/bin/sh
# ash: показать/спрятать tray с его колпачками (вынесено из click-left:
# polybar обрезает ini-значения по ';')
for m in tray ahi ahd; do
    polybar-msg action "#$m.module_toggle" >/dev/null 2>&1
done
