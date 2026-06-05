#!/bin/sh
# ash: контейнеры для polybar — число запущенных (+ остановленные, если есть).
# Пусто, если docker недоступен (модуль скрывается сам).
command -v docker >/dev/null || exit 0
running=$(timeout 3 docker ps -q 2>/dev/null | wc -l) || exit 0
total=$(timeout 3 docker ps -aq 2>/dev/null | wc -l)
stopped=$((total - running))
if [ "$stopped" -gt 0 ]; then
    printf '%s/%s\n' "$running" "$total"
else
    printf '%s\n' "$running"
fi
