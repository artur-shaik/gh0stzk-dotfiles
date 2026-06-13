#!/bin/sh
# ash: taskwarrior-tui во floating-окне (клик по tasks-пилюле).
# Репорт `polybar` (status:pending, сорт urgency-, кастом-колонки) задан в taskrc.
# ВАЖНО: НЕ пихать сложный фильтр пилюли (taskinfilter.sh) в tui —
#   taskwarrior-tui берёт таски через `task export`, а тот: (1) дробит фильтр по
#   пробелам → скобки/кавычки в `project:'Личные дела'` ломаются («Mismatched
#   parentheses»), (2) ИГНОРИРУЕТ context (count применяет, export нет).
#   Поэтому tui-safe фильтр = простой `status:pending`; точечно фильтровать в tui
#   живьём клавишей `/`. (Раньше был vit с тем фильтром одним аргументом.)
exec alacritty --class TaskList -e taskwarrior-tui -r polybar
