#!/bin/sh
# ash: индикатор security-scan для polybar (пилюльный модуль через pill-wrap.sh)
#   alert — текст если есть флаг угрозы (живёт до 'sudo secscan-ack')
#   scan  — какой движок сканирует прямо сейчас (clamav / rootkit)
# Пустой вывод -> pill-wrap скрывает пилюлю.
ALERT=/var/lib/security-scan/ALERT

case "$1" in
  alert)
    [ -f "$ALERT" ] && echo "угроза"
    ;;
  scan)
    if pgrep -x clamdscan >/dev/null 2>&1 || pgrep -x clamscan >/dev/null 2>&1; then
      echo "clamav"
    elif pgrep -x chkrootkit >/dev/null 2>&1 || pgrep -x rkhunter >/dev/null 2>&1; then
      echo "rootkit"
    fi
    ;;
esac
