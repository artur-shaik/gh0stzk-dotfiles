#!/bin/sh
# ash: vit во floating-окне (клик по tasks-пилюле).
# taskwarrior-tui лежит в ~/.local/bin, но требует taskwarrior 3.x —
# после миграции с 2.x переключить exec на него.
exec alacritty --class TaskList -e vit
