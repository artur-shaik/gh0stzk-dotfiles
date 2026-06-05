#!/bin/sh
# ash: bluetooth для пилюли. Подключено -> "<bt-icon> Имя", иначе только
# off-иконка (пилюля видна всегда — через неё подключают устройства).
name=$(bash "$HOME/.config/polybar/scripts/bluetooth-device.sh" 2>/dev/null | grep -v '^$')
case "$name" in
    ""|"") printf '󰂲\n' ;;
    *)      printf '󰂯 %s\n' "$name" ;;
esac
