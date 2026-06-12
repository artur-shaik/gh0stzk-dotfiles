#!/bin/sh
# ash: ГИБРИД — 5 wal-цветов (их hue/sat), яркость по ступеням
# (grad1 тёмный → grad5 светлый). Разные цвета + ровный градиент, обе темы.
#
# ДВА АЛГОРИТМА (переключатель: env GRAD_ALGO, иначе файл
# ~/.config/bspwm/.grad-algo, иначе дефолт 'perceptual'):
#   perceptual — целевой CIELAB L* [50,60,70,79,87], под каждый hue ищем
#     HLS-lightness бинпоиском до нужной отн. яркости Y. L* линеен глазу →
#     ступени РОВНЫЕ независимо от тона (красный/жёлтый одинаково ярки).
#   hls        — старый: фикс HLS-lightness [0.3..0.7]. Проще, но равный L
#     у разных hue = разная видимая яркость (бордовый «ямой» меж оранжевых).
ALGO="${GRAD_ALGO:-$(cat "$HOME/.config/bspwm/.grad-algo" 2>/dev/null)}"
ALGO="${ALGO:-perceptual}"

GRAD_ALGO="$ALGO" python3 - <<'PY'
import re, colorsys, os
ALGO=os.environ.get('GRAD_ALGO','perceptual')
t=open(os.path.expanduser('~/.cache/wal/colors.sh')).read()
g=lambda k:re.search(rf"{k}='(#......)'",t).group(1)
cols=[g(f'color{i}') for i in (1,2,3,4,5)]   # red green yellow blue magenta
def rgb(h): return tuple(int(h[i:i+2],16)/255 for i in (1,3,5))
def hexs(r,g,b): return '#%02x%02x%02x'%(round(r*255),round(g*255),round(b*255))
SAT_FLOOR=0.35

if ALGO=='hls':
    # старый: фикс HLS-lightness тёмный->светлый
    L=[0.30,0.40,0.50,0.60,0.70]
    out=[]
    for c,l in zip(cols,L):
        r,gr,b=rgb(c)
        h,_,s=colorsys.rgb_to_hls(r,gr,b)
        s=max(s,SAT_FLOOR)
        out.append(hexs(*colorsys.hls_to_rgb(h,l,s)))
else:
    # перцептивный: ровные ступени CIELAB L*
    def lin(c):  # sRGB -> линейный свет
        return c/12.92 if c<=0.04045 else ((c+0.055)/1.055)**2.4
    def relY(r,g,b):
        return 0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b)
    def Lstar_to_Y(L):
        fy=(L+16)/116
        return fy**3 if L>8 else L/903.3
    TARGETS=[Lstar_to_Y(l) for l in (50,60,70,79,87)]
    out=[]
    for c,yt in zip(cols,TARGETS):
        r,gr,b=rgb(c)
        h,_,s=colorsys.rgb_to_hls(r,gr,b)
        s=max(s,SAT_FLOOR)
        lo,hi=0.0,1.0
        for _ in range(40):
            mid=(lo+hi)/2
            rr,gg,bb=colorsys.hls_to_rgb(h,mid,s)
            if relY(rr,gg,bb)<yt: lo=mid
            else: hi=mid
        out.append(hexs(*colorsys.hls_to_rgb(h,(lo+hi)/2,s)))
print('\n'.join(out))
PY
