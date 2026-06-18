#!/bin/sh
# ash: toggle polybar module mode (full <-> min) for ONE monitor, relaunch only
# that monitor's bar. No arg = focused monitor. Called by hotkey + barmode click.
mon="${1:-$(bspc query -M -m focused --names 2>/dev/null)}"
[ -n "$mon" ] || exit 0
modef="$HOME/.cache/polybar-mode-$mon"
if [ "$(cat "$modef" 2>/dev/null)" = min ]; then
    echo full > "$modef"
else
    echo min > "$modef"
fi
read -r RICE < "$HOME/.config/bspwm/.rice"
export RICE PATH="$HOME/.config/bspwm/bin:$PATH"
exec bash "$HOME/.config/bspwm/rices/$RICE/Bar.bash" "$mon"
