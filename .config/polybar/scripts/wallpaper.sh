#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/.config/swww/"

# File to store the current wallpaper path
CURRENT_WALLPAPER_FILE="$WALLPAPER_DIR/wallpaper.rofi"

# Get a list of image files in the directory
WALLPAPERS=("$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.png)

# Find the index of the next wallpaper in the array
NEXT_INDEX=$(($(($RANDOM % ${#WALLPAPERS[@]})) - 1))

# Set the next wallpaper using feh img with the full path
feh --bg-fill "${WALLPAPERS[$NEXT_INDEX]}" ; wal -i "${WALLPAPERS[$NEXT_INDEX]}" -n

# Copy the currently set wallpaper to current_wallpaper.rofi
cp "${WALLPAPERS[$NEXT_INDEX]}" "$CURRENT_WALLPAPER_FILE"

# polybar script
~/.config/polybar/scripts/wal-polybar.py
# cava
cp ~/.cache/wal/colors-cava ~/.config/cava/config
# kitty 
cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/
# mako
cp ~/.cache/wal/colors-mako ~/.config/mako/config
# rofi 
cp ~/.cache/wal/colors-rofi.rasi ~/.config/rofi/colors/colors-rofi.rasi
# firefox
pywalfox update
