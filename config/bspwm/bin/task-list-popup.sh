#!/bin/sh
# ash: список задач taskwarrior во floating-окне (клик по tasks-пилюле).
# Вынесено из click-left: polybar обрезает ini-значения по ';'.
# Фильтр передаётся ОДНИМ аргументом (как в tstats.sh) — в нём кавычки
# и скобки, word-splitting в sh его ломает.
exec alacritty --class TaskList -e sh -c '
    filter=$(taskinfilter.sh)
    task "$filter" +PENDING
    echo
    echo "--- сегодня ---"
    task +today +PENDING 2>/dev/null
    echo
    echo "Enter — закрыть"
    read -r _'
