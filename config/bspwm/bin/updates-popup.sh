#!/bin/sh
# ash: список доступных zypper-обновлений в floating-окне с пейджером
# (его Updates --print-updates печатал и сразу закрывал окно).
exec alacritty --class TaskList -e sh -c '
    zypper -q list-updates 2>/dev/null | less -S'
