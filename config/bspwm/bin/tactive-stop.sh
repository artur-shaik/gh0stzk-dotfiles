#!/bin/sh
# ash: ПКМ по пилюле активной задачи — остановить трекинг показываемой задачи.
STATE="${XDG_RUNTIME_DIR:-/tmp}/tactive-current"
uuid=$(cut -f1 "$STATE" 2>/dev/null)
[ -n "$uuid" ] && task rc.confirmation=no "$uuid" stop >/dev/null 2>&1
