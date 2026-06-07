#!/bin/sh
# ash: лирика внутри eww-плеера (revealer): тоггл + загрузка текста
export PATH="$HOME/.config/bspwm/bin:$PATH"
EWW="eww -c $HOME/.config/bspwm/eww"

# --refresh: перезагрузить текст (зовёт listen-демон при смене трека),
# только когда секция открыта; тоггл не трогаем
if [ "$1" = "--refresh" ]; then
    [ "$($EWW get lyrics-open 2>/dev/null)" = "true" ] || exit 0
    f=$(MediaControl --lyrics)
    if [ -n "$f" ] && [ -s "$f" ]; then
        $EWW update lyrics-text="$(cat "$f")"
    else
        $EWW update lyrics-text="(текст не найден)"
    fi
    exit 0
fi

if [ "$($EWW get lyrics-open 2>/dev/null)" = "true" ]; then
    $EWW update lyrics-open=false
    exit 0
fi
f=$(MediaControl --lyrics)
if [ -n "$f" ] && [ -s "$f" ]; then
    $EWW update lyrics-text="$(cat "$f")" lyrics-open=true
else
    $EWW update lyrics-text="(текст не найден)" lyrics-open=true
fi
