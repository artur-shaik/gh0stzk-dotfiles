#!/bin/sh
# =============================================================
#  ████████╗██╗  ██╗███████╗███╗   ███╗███████╗
#  ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝
#     ██║   ███████║█████╗  ██╔████╔██║█████╗
#     ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝
#     ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗
#     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝
# Author: gh0stzk
# Repo:   https://github.com/gh0stzk/dotfiles
# Date:   10.11.2025
# Info:   This file will configure and launch the rice.
#
# Copyright (C) 2021-2026 gh0stzk <z0mbi3.zk@protonmail.com>
# Licensed under GPL-3.0 license
# =============================================================

# Current Rice
read -r RICE < "$HOME"/.config/bspwm/.rice
# Load theme configuration
. "$HOME"/.config/bspwm/rices/"$RICE"/theme-config.bash

# ====================================================================
# ash: палитра и обои — ПОЛЬЗОВАТЕЛЬСКИЕ, от pywal (theme_select.sh / wal).
# Райс даёт только layout. Обои райса не используются: модулю 06
# подсовываем текущие wal-обои (ENGINE=Default), wal НЕ перегенерируем —
# палитра уже от этих обоев. Переменные theme-config переопределяются.
# ====================================================================
export PATH="$HOME/.config/bspwm/bin:$PATH"

if [ -r "$HOME/.cache/wal/wal" ]; then
    read -r CUR_WALL < "$HOME/.cache/wal/wal"
    if [ -f "$CUR_WALL" ]; then
        ENGINE="Default"
        DEFAULT_WALL="$CUR_WALL"
    fi
fi

if [ -r "$HOME/.cache/wal/colors.sh" ]; then
    . "$HOME/.cache/wal/colors.sh"
    bg="$background"   fg="$foreground"
    black="$color0"    red="$color1"       green="$color2"   yellow="$color3"
    blue="$color4"     magenta="$color5"   cyan="$color6"    white="$color7"
    blackb="$color8"   redb="$color9"      greenb="$color10" yellowb="$color11"
    blueb="$color12"   magentab="$color13" cyanb="$color14"  whiteb="$color15"
    accent_color="$color4"
    NORMAL_BC="$color0"
    FOCUSED_BC="$color4"

    # Перекраска захардкоженных hex'ов бара райса (polybar ini / eww scss)
    # ближайшими wal-цветами. Pristine-копии — *.orig (см. wal-recolor).
    "$HOME"/.config/bspwm/bin/wal-recolor \
        "$HOME/.config/bspwm/rices/$RICE/theme-config.bash" \
        "$HOME/.config/bspwm/rices/$RICE/config.ini" \
        "$HOME/.config/bspwm/rices/$RICE/modules.ini" \
        "$HOME/.config/bspwm/rices/$RICE/bar/eww.scss" 2>/dev/null || true
fi
# ==================== /ash ====================

# Path to modules dir
MODULE_DIR="$HOME/.config/bspwm/config/modules"


# Load all the files in dir
for module in "$MODULE_DIR"/*.sh; do
    . "$module"
done

# ash: self-heal picom — модуль 01 правит picom.conf sed'ом под живым
# picom (v13 авторелоадит конфиг и может упасть на полузаписанном файле)
sleep 1
if ! pgrep -x picom >/dev/null; then
    picom --config "$HOME/.config/bspwm/config/picom.conf" -b
fi
