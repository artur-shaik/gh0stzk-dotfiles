#!/bin/sh
# ash: 5 ступеней accent(color4) -> fg. Выраженный размах, цветной к светлому.
# Тёмный конец = насыщенный accent, светлый = fg. Работает в обеих темах.
python3 - <<'PY'
import re
t=open('/home/ash/.cache/wal/colors.sh').read()
g=lambda k:re.search(rf"{k}='(#......)'",t).group(1)
a=g('color4'); f=g('foreground')
rgb=lambda h:tuple(int(h[i:i+2],16) for i in (1,3,5))
A,F=rgb(a),rgb(f)
steps=['#'+''.join(f'{round(A[k]+(F[k]-A[k])*(0.15+i*0.8/4)):02x}' for k in range(3)) for i in range(5)]
# grad1 ВСЕГДА самый тёмный (правый край), grad5 светлый — независимо от темы
lum=lambda h:0.2126*int(h[1:3],16)+0.7152*int(h[3:5],16)+0.0722*int(h[5:7],16)
for c in sorted(steps,key=lum):
    print(c)
PY
