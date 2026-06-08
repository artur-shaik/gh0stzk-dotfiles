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
for i in range(5):
    t=0.15+i*0.8/4   # 0.15..0.95
    print('#'+''.join(f'{round(A[k]+(F[k]-A[k])*t):02x}' for k in range(3)))
PY
