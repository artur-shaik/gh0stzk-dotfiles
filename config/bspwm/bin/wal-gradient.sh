#!/bin/sh
# ash: ГИБРИД — 5 wal-цветов (их hue/sat), яркость выровнена по ступеням
# (grad1 тёмный → grad5 светлый). Разные цвета + ровный градиент, обе темы.
python3 - <<'PY'
import re, colorsys
t=open('/home/ash/.cache/wal/colors.sh').read()
g=lambda k:re.search(rf"{k}='(#......)'",t).group(1)
cols=[g(f'color{i}') for i in (1,2,3,4,5)]   # red green yellow blue magenta
def rgb(h): return tuple(int(h[i:i+2],16)/255 for i in (1,3,5))
def hexs(r,g,b): return '#%02x%02x%02x'%(round(r*255),round(g*255),round(b*255))
# целевая светлота тёмный->светлый
L=[0.30,0.40,0.50,0.60,0.70]
out=[]
for c,l in zip(cols,L):
    r,gr,b=rgb(c)
    h,_,s=colorsys.rgb_to_hls(r,gr,b)
    s=max(s,0.35)              # не дать серости (бедная палитра)
    out.append(hexs(*colorsys.hls_to_rgb(h,l,s)))
print('\n'.join(out))
PY
