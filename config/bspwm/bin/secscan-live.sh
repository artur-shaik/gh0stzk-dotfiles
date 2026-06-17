#!/bin/sh
# ash: live-монитор security-scan (клик по scan-пилюле). clamdscan пишет в лог
# тихо (только угрозы, нет прогресс-%), поэтому показываем ЖИВОСТЬ: статус
# сервиса, аптайм, активные движки/воркеры, текущие сканируемые файлы
# (открытые fd демона clamd), хвост лога. sudo — для root-лога и /proc/fd.
LOG="/var/log/security-scan/scan-$(date +%F).log"

# прогреть sudo один раз (дальше из кэша), чтоб watch-цикл не спрашивал пароль
sudo -v 2>/dev/null || { echo "нужен sudo"; sleep 2; exit 1; }

running() { systemctl is-active --quiet security-scan.service \
            || systemctl is-active --quiet security-scan-full.service \
            || pgrep -x clamdscan >/dev/null 2>&1 \
            || pgrep -x clamscan  >/dev/null 2>&1 \
            || pgrep -x chkrootkit >/dev/null 2>&1; }

while :; do
    clear
    if running; then st="🟢 идёт"; else st="⚪ простой"; fi
    printf '\033[1m🛡  Security scan — %s\033[0m\n' "$st"

    # аптайм активного юнита
    for u in security-scan.service security-scan-full.service; do
        if systemctl is-active --quiet "$u"; then
            since=$(systemctl show -p ActiveEnterTimestamp --value "$u" 2>/dev/null)
            [ -n "$since" ] && printf '  юнит %s, старт: %s\n' "$u" "$since"
        fi
    done

    # активные движки / воркеры
    cw=$(pgrep -xc clamdscan 2>/dev/null || echo 0)
    [ "$cw" -gt 0 ] 2>/dev/null && printf '  ClamAV: %s воркеров (clamdscan)\n' "$cw"
    pgrep -x clamscan  >/dev/null 2>&1 && printf '  ClamAV: clamscan (однопоточно)\n'
    pgrep -x chkrootkit >/dev/null 2>&1 && printf '  chkrootkit: идёт\n'
    pgrep -x freshclam >/dev/null 2>&1 && printf '  freshclam: обновление сигнатур\n'

    # текущие сканируемые файлы — открытые fd демоном clamd (дёшево, один демон)
    cd=$(pgrep -x clamd | head -1)
    if [ -n "$cd" ]; then
        printf '\n\033[2m── сейчас сканируется ──\033[0m\n'
        sudo ls -l "/proc/$cd/fd" 2>/dev/null \
          | sed -n 's|.*-> \(/.*\)|  \1|p' \
          | grep -vE '/(dev|proc|run|socket|var/lib/clamav|/.*\.cvd|/.*\.cld)' \
          | grep -E '^\s+/' | head -8
    fi

    # хвост лога (фазы + угрозы)
    printf '\n\033[2m── лог (хвост) ──\033[0m\n'
    sudo tail -n 8 "$LOG" 2>/dev/null | sed 's/^/  /'

    running || { printf '\n\033[1mскан завершён.\033[0m [Enter] закрыть\n'; read -r _; break; }
    sleep 1.5
done
