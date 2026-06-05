#!/bin/sh
# ash: taskwarrior-tui во floating-окне (клик по tasks-пилюле).
# Вынесено из click-left: polybar обрезает ini-значения по ';'.
exec alacritty --class TaskList -e taskwarrior-tui
