#!/bin/sh
# ash: mpd для polybar. "[artist - ]title" — артист только если задан.
# Хост выбирает обёртка bspwm/bin/mpc (активный: remote или localhost).
export PATH="$HOME/.config/bspwm/bin:$PATH"

# Антимерцание: remote-mpd блипает (коннект-фейл -> mpc rc!=0, ИЛИ обёртка
# фоллбечит на idle-localhost -> rc=0 но пусто). Любое "нет данных" не прячем
# сразу — держим последнюю плашку GRACE секунд (кэш). Реальный stop тоже
# повисит GRACE сек и исчезнет — приемлемо, блипы ~2с укладываются.
CACHE=/tmp/.mpd-pill-last
TS=/tmp/.mpd-pill-ts
GRACE=8

# mpc-скобки прячутся, только если ВСЕ теги внутри пусты:
# [[%artist% - ]%title%] -> внутренняя скобка изолирует артиста:
# оба тега -> "artist - title"; только title -> "title"; пусто -> fallback ниже
# лимит длины — от ширины монитора этого бара (env MONITOR от Bar.bash):
# на ноуте 1920px длинный mpd выжимает правый край бара за экран
# ширину берём из кэша MonitorSetup: xrandr в поллере = ежесекундный
# EDID-опрос монитора, спам журнала и дестабилизация modeset
w=$(cat "/tmp/.mon-width.${MONITOR:-eDP-1}" 2>/dev/null)
limit=$(( (${w:-1920} - 1500) / 9 ))
[ "$limit" -lt 25 ] && limit=25
[ "$limit" -gt 70 ] && limit=70

cur=$(mpc current -f '[[%artist% - ]%title%]' 2>/dev/null | cut -c1-$limit)
# трек без тегов: показать имя файла (без пути и расширения)
if [ -z "$cur" ]; then
    cur=$(mpc current -f '%file%' 2>/dev/null | sed 's|.*/||; s|\.[a-zA-Z0-9]*$||' | cut -c1-$limit)
fi

# нет данных (блип/стоп): в пределах grace — отдать последнюю плашку
if [ -z "$cur" ]; then
    last=$(cat "$TS" 2>/dev/null)
    now=$(date +%s)
    if [ -n "$last" ] && [ $(( now - ${last:-0} )) -lt "$GRACE" ]; then
        cat "$CACHE" 2>/dev/null
    else
        : > "$CACHE"   # grace вышел -> прячем (pill-wrap на пустой строке)
    fi
    exit 0
fi

state=$(mpc status 2>/dev/null | sed -n '2s/^\[\([a-z]*\)\].*/\1/p')
if [ "$state" = "playing" ]; then
    icon="󰐊"
else
    icon="󰏤"
fi

line=$(printf '%s %s' "$icon" "$cur")
printf '%s\n' "$line"
printf '%s\n' "$line" > "$CACHE"
date +%s > "$TS"
