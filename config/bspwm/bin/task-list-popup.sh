#!/bin/sh
# ash: vit во floating-окне (клик по tasks-пилюле), с тем же фильтром,
# что у счётчика (taskinfilter.sh) — фильтр ОДНИМ аргументом.
# taskwarrior-tui в ~/.local/bin ждёт миграции на taskwarrior 3.x.
filter=$(taskinfilter.sh)
exec alacritty --class TaskList -e vit "$filter" +PENDING
