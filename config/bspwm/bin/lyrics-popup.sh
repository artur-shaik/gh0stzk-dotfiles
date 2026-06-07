#!/bin/sh
# ash: текст текущего трека (MediaControl --lyrics, lrclib) во float-окне
export PATH="$HOME/.config/bspwm/bin:$PATH"
f=$(MediaControl --lyrics)
if [ -n "$f" ] && [ -s "$f" ]; then
    exec alacritty --class Lyrics -e less "$f"
else
    notify-send "Lyrics" "Текст не найден"
fi
