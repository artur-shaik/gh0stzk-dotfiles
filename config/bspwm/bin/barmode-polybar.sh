#!/bin/sh
# ash: icon for the bar-mode toggle module. full = dashboard, min = minus.
# arg = monitor; comes from the module via `sh -c '... "$MONITOR"'` (polybar's
# ${env:MONITOR} substitution returns empty here, so use shell $MONITOR at runtime).
mon="$1"
if [ "$(cat "$HOME/.cache/polybar-mode-$mon" 2>/dev/null)" = min ]; then
    printf '\363\260\215\264\n'   # mdi minus (min mode)
else
    printf '\363\260\225\256\n'   # mdi view-dashboard (full mode)
fi
