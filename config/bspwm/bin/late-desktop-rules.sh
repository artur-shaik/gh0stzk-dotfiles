#!/bin/sh
# ash: re-place windows whose WM_CLASS is set AFTER the window is mapped
# (qutebrowser, electron apps, ...). bspwm runs external_rules AT map time and
# sees an empty class -> the desktop= rule misses -> the window stays on the
# focused desktop. node_add fires once the class is available (xprop sees it,
# same as window-blackbox); retry briefly in case it's still settling, then move.
#
# Keep the target map in sync with bin/ExternalRules (fast path when class is
# ready; this is the race fallback). cur==tgt is skipped so no double-move/jump.

bspc subscribe node_add | while read -r _ _ _ _ wid; do
    [ -n "$wid" ] || continue
    cls=""
    i=0
    while [ "$i" -lt 8 ]; do
        cls=$(xprop -id "$wid" WM_CLASS 2>/dev/null)
        [ -n "$cls" ] && break
        i=$((i + 1))
        sleep 0.1
    done
    # tgt = positional ^N (1-based, matches super+N / ExternalRules), NOT name.
    case "$cls" in
        *'"qutebrowser"'*)          tgt='^6' ;;
        *TelegramDesktop*)          tgt='^4' ;;
        *'"firefox"'* | *Navigator*) tgt='^9' ;;
        *) continue ;;
    esac
    tgtname=$(bspc query -D -d "$tgt" --names 2>/dev/null)
    cur=$(bspc query -D -n "$wid" --names 2>/dev/null)
    [ "$cur" = "$tgtname" ] || bspc node "$wid" -d "$tgt" --follow
done
