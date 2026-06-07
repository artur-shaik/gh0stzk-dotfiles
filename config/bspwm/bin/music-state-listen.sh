#!/bin/sh
# ash: единое состояние плеера для eww (deflisten) — вместо 11 параллельных
# defpoll'ов, чей залп TCP-коннектов давил серверный mpd (звук икал).
# JSON раз в секунду; тяжёлые поля (current/art) — раз в 3 тика.
export PATH="$HOME/.config/bspwm/bin:$PATH"

title=""; artist=""; art=""
tick=0
while :; do
    st=$(mpc status 2>/dev/null)
    if [ -z "$st" ]; then
        printf '{"status":"Stopped","title":"","artist":"","art":"","position":"0:00","positions":0,"length":"0:00","lengths":0,"shuffle":"Off","loop":"Off","player":"MPD"}\n'
        sleep 3
        continue
    fi
    state=$(printf '%s' "$st" | sed -n '2s/^\[\([a-z]*\)\].*/\1/p')
    case "$state" in
        playing) status="Playing" ;;
        paused)  status="Paused" ;;
        *)       status="Stopped" ;;
    esac
    pos=$(printf '%s' "$st" | sed -n '2s/.* \([0-9:]*\)\/[0-9:]*.*/\1/p')
    len=$(printf '%s' "$st" | sed -n '2s/.*\/\([0-9:]*\).*/\1/p')
    secs() { printf '%s' "$1" | awk -F: 'NF==2{print $1*60+$2} NF==3{print $1*3600+$2*60+$3} NF<2{print 0}'; }
    rnd=$(printf '%s' "$st" | sed -n 's/.*random: \([a-z]*\).*/\1/p')
    rpt=$(printf '%s' "$st" | sed -n 's/.*repeat: \([a-z]*\).*/\1/p')
    [ "$rnd" = "on" ] && shuffle="On" || shuffle="Off"
    [ "$rpt" = "on" ] && loop="On" || loop="Off"

    if [ $((tick % 3)) -eq 0 ] || [ -z "$title" ]; then
        cur=$(mpc current -f '%title%\t[[%artist%]]' 2>/dev/null)
        title=${cur%%	*}
        artist=${cur#*	}
        [ "$artist" = "$cur" ] && artist=""
        art=$(MediaControl --cover 2>/dev/null)
    fi
    tick=$((tick + 1))

    jq -cn --arg t "$title" --arg a "$artist" --arg s "$status" --arg art "$art" \
        --arg p "${pos:-0:00}" --arg l "${len:-0:00}" \
        --argjson ps "$(secs "${pos:-0}")" --argjson ls "$(secs "${len:-0}")" \
        --arg sh "$shuffle" --arg lp "$loop" \
        '{title:$t, artist:$a, status:$s, art:$art, position:$p, length:$l,
          positions:$ps, lengths:$ls, shuffle:$sh, loop:$lp, player:"MPD"}'
    sleep 1
done
