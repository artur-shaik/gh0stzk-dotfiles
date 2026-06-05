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
# ash: динамическая палитра через pywal — цвета от обоев, не от райса.
# Обои выбираем ДО модулей (модуль 06 получит ENGINE=Default + DEFAULT_WALL),
# wal генерит палитру, переменные theme-config переопределяются.
# Animated/Slideshow — wal не прогоняем, остаётся палитра райса.
# ====================================================================
pick_wal_img() {
    find "$1" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1
}

WAL_IMG=""
case "${ENGINE:-Default}" in
    Random)
        WAL_IMG=$(pick_wal_img "$HOME/.config/bspwm/rices/$RICE/walls")
        ENGINE="Default"; DEFAULT_WALL="$WAL_IMG"
        ;;
    CustomDir)
        WAL_IMG=$(pick_wal_img "$CUSTOM_DIR")
        ENGINE="Default"; DEFAULT_WALL="$WAL_IMG"
        ;;
    Default)
        WAL_IMG="$DEFAULT_WALL"
        ;;
esac

if [ -n "$WAL_IMG" ] && command -v wal >/dev/null; then
    wal -n -q -e -i "$WAL_IMG" || true
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
    fi
fi
# ==================== /ash ====================

# Path to modules dir
MODULE_DIR="$HOME/.config/bspwm/config/modules"


# Load all the files in dir
for module in "$MODULE_DIR"/*.sh; do
    . "$module"
done
