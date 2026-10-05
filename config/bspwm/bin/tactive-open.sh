#!/bin/sh
# ash: ЛКМ по пилюле активной задачи — tw-pick (next) по проекту показываемой.
# Проект берём из statefile, который пишет tactive-polybar.sh.
STATE="${XDG_RUNTIME_DIR:-/tmp}/tactive-current"
proj=$(cut -f2 "$STATE" 2>/dev/null)
if [ -n "$proj" ]; then
    setsid -f alacritty --class TaskPad -e tw-pick --report next "project:$proj" >/dev/null 2>&1 </dev/null
else
    setsid -f alacritty --class TaskPad -e tw-pick --report next >/dev/null 2>&1 </dev/null
fi
