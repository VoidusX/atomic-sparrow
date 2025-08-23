#!/bin/bash

echo "Setting up end-4 dotfiles for default post-install."
# Python packages for UV enviornment (disabled because it breaks anaconda installer)
# install --setopt=install_weak_deps=False python3 python3-devel python3.12 python3.12-devel libsoup-devel

# Gnome GTK3/4 libraries (disabled because it breaks anaconda installer)
# install libadwaita-devel gtk-layer-shell-devel gtk3 gtksourceview3 gtksourceview3-devel gobject-introspection upower \
# gtksourceviewmm3-devel webp-pixbuf-loader gobject-introspection-devel gjs gjs-devel pulseaudio-libs-devel \
# gnome-bluetooth bluez-cups bluez mate-polkit translate-shell
install --setopt=install_weak_deps=False upower bluez-cups bluez translate-shell

# Utilities
install --setopt=install_weak_deps=False wl-clipboard xdg-utils fuzzel ripgrep gojq npm typescript axel eza brightnessctl ddcutil

# Audio/Media libraries
install --setopt=install_weak_deps=False pavucontrol playerctl cava #libdbusmenu-gtk3-devel libdbusmenu playerctl cava

# Misc tooling
install --setopt=install_weak_deps=False yad scdoc ydotool tinyxml tinyxml2 libsass

# Misc tooling dev files
install --setopt=install_weak_deps=False tinyxml2-devel file-devel libwebp-devel libdrm-devel libgbm-devel pam-devel libsass-devel

# end-4 dotfiles theming
install --setopt=install_weak_deps=False adw-gtk3-theme qt5ct qt6-qtwayland qt5-qtwayland fontconfig jetbrains-mono-fonts gdouros-symbola-fonts lato-fonts darkly fish kitty starship \
kvantum kvantum-qt5 libxdp-devel libxdp libportal google-rubik-fonts

# Screenshot/Recording tools
install --setopt=install_weak_deps=False swappy wf-recorder grim tesseract slurp

# Appstream & Web libaries
install --setopt=install_weak_deps=False appstream-util libsoup3-devel

# end-4 quickshell features
# python-opencv was removed because it requires python, which is disabled.
install --setopt=install_weak_deps=False plasma-nm kdialog bluedevil plasma-systemmonitor wtype matugen grimblast mpvpaper ffmpeg #kde-material-you-colors (requires python but anaconda installer breaks)

# Drop the repos as we dont need to keep them around anymore
drop atim/starship
drop deltacopy/darkly
