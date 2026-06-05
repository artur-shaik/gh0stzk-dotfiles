#!/bin/sh
# ash: список задач taskwarrior во floating-окне (клик по tasks-пилюле).
# Вынесено из click-left: polybar обрезает ini-значения по ';'.
exec alacritty --class TaskList -e sh -c '
    task $(taskinfilter.sh) +PENDING
    echo
    task +today +PENDING 2>/dev/null
    echo
    echo "Enter — закрыть"
    read -r _'
