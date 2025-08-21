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
hyprsysteminfo \
hyprwayland-scanner \
hyprpicker \
hyprshot \
hyprlang-devel

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
# hyprpicker => Color picker
# hyprshot => Screenshot utility
# hyprlang-devel => developer packages of hyprlang (needed by end-4)

echo "Installing Hyprland. (2/3)"
# These are packages that allows support for different dotfile configurations other than end-4, though some end-4 required dependencies are found here.
install rofi waypaper swww \
cliphist nwg-look qt6ct \
nwg-dock-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-kde \
wlogout waybar nautilus pugixml rsync

echo "Installing Hyprland. (3/3)"
install bibata-cursor-theme uv ghostty fastfetch sox quickshell-git ocean-sound-theme

# Bibata Cursors is the default cursor theme used by Sparrow.
# Ghostty is the default terminal of hyprland image, used by Sparrow OOBE.
# Fastfetch is the CLI information page on installation.
# sox adds the 'play' command which is commonly used to play a audio file.
# Ocean Sound Theme is the default sound theme used by Sparrow.
# quickshell-git is the git version of quickshell (needed by end-4)

drop solopasha/hyprland # Remove repo after packages are installed.
drop errornointernet/quickshell
