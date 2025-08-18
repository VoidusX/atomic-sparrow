#!/bin/bash
echo "Installing Hyprland. (1/3)"
# Essential Hyprland components.
install hyprland \
hyprland-plugins \
hyprland-contrib \
hyprpaper \
hyprsunset \
xdg-desktop-portal-hyprland \
hyprlock \
hypridle \
hyprpolkitagent \
hyprsysteminfo

# hyprland => Compositor WM
# hyprland-plugins => Plugin support for Hyprland
# hyprland-contrib => Community-extended support for Hyprland (grimblast, etc.)
# hyprpaper => Official Wallpaper System
# hyprsunset => Daytime aware screen adjuster
# hyprlock => Lockscreen for hyprland, a setting in shell is provided for autologin lock
# hypridle => Time aware idling system for Hyprland
# hyprpolkitagent => GUI Authentication for actions requiring admin privilages
# hyprsysteminfo => GUI information page on installation
# xdg-desktop-portal-hyprland => Handles portal requests for screensharing screens

echo "Installing Hyprland. (2/3)"
# These are temporary packages until a quickshell enviornment is found.
install rofi waypaper swww \
cliphist nwg-look qt6ct \
nwg-dock-hyprland xdg-desktop-portal-gtk \
wlogout waybar nautilus

echo "Installing Hyprland. (3/3)"
install bibata-cursor-theme ghostty fastfetch sox

# Bibata Cursors is the default theme of the hyprland image.
# Ghostty is the default terminal
# Fastfetch is the CLI information page on installation.
# sox adds the 'play' command which is commonly used to play a audio file.

drop solopasha/hyprland # Remove repo after packages are installed.
