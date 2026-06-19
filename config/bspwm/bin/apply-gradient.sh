#!/bin/sh
# ash: вписать grad1..5 (от wal-gradient) в РАБОЧИЙ config.ini текущего райса.
# Зовётся ПОСЛЕ wal-recolor (иначе recolor перекрашивает grad-hex по семантике).
export PATH="$HOME/.config/bspwm/bin:$PATH"
read -r RICE < "$HOME/.config/bspwm/.rice"
CFG="$HOME/.config/bspwm/rices/$RICE/config.ini"
[ -f "$CFG" ] || exit 0
i=1
for g in $(wal-gradient.sh); do
    if grep -q "^grad$i = " "$CFG"; then
        sed -i "s/^grad$i = .*/grad$i = $g/" "$CFG"
    else
        sed -i "s/^\[color\]/[color]\ngrad$i = $g/" "$CFG"
    fi
    i=$((i+1))
done

# ash: gradtext — текст для модулей на ТЁМНЫХ grad-фонах (grad1/grad2 = самые
# тёмные ступени всегда). = светлейший из bg/fg (в светлой палитре это bg, в
# тёмной fg — нет статичной роли, recolor бы сожрал хардкод). Вписываем ПОСЛЕ
# recolor (как grad). date label-foreground = ${color.gradtext}.
bg=$(awk -F= '/^bg =/{gsub(/ /,"",$2);print $2;exit}' "$CFG")
fg=$(awk -F= '/^fg =/{gsub(/ /,"",$2);print $2;exit}' "$CFG")
gt=$(python3 - "$bg" "$fg" <<'PY'
import sys
def lum(h):
    h=h.lstrip('#')[-6:]
    r,g,b=(int(h[i:i+2],16)/255 for i in (0,2,4))
    f=lambda c:(c/12.92 if c<=.03928 else ((c+.055)/1.055)**2.4)
    return .2126*f(r)+.7152*f(g)+.0722*f(b)
bg,fg=sys.argv[1],sys.argv[2]
print(bg if lum(bg)>=lum(fg) else fg)
PY
)
[ -n "$gt" ] || gt="$bg"
if grep -q "^gradtext = " "$CFG"; then
    sed -i "s/^gradtext = .*/gradtext = $gt/" "$CFG"
else
    sed -i "s/^\[color\]/[color]\ngradtext = $gt/" "$CFG"
fi
