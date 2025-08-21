#!/bin/bash

shared="/usr/share"
assets="/imageAssets"
patches="/tmp/opt/hyprland.theme.patches"

echo "Setting up end-4 dotfiles for default post-install."
# Python packages for UV enviornment
install python3 python3-devel python3.12 python3.12-devel libsoup-devel

# Gnome GTK3/4 libraries
install libadwaita-devel gtk-layer-shell-devel gtk3 gtksourceview3 gtksourceview3-devel gobject-introspection upower \
gtksourceviewmm3-devel webp-pixbuf-loader gobject-introspection-devel gjs-devel pulseaudio-libs-devel \
gnome-bluetooth bluez-cups bluez mate-polkit translate-shell

# Utilities
install coreutils wl-clipboard xdg-utils curl fuzzel rsync wget ripgrep gojq npm meson typescript gjs axel eza brightnessctl ddcutil

# Audio/Media libraries
install pavucontrol wireplumber libdbusmenu-gtk3-devel libdbusmenu playerctl cava

# Misc tooling
install yad scdoc ydotool tinyxml tinyxml2 tinyxml2-devel file-devel libwebp-devel libdrm-devel libgbm-devel pam-devel libsass-devel libsass

# end-4 dotfiles theming
install gnome-themes-extra adw-gtk3-theme qt5ct qt6-qtwayland kcmshell6 qt5-qtwayland fontconfig jetbrains-mono-fonts gdouros-symbola-fonts lato-fonts darkly fish kitty starship \
kvantum kvantum-qt5 libxdp-devel libxdp libportal google-rubik-fonts

# Screenshot/Recording tools
install swappy wf-recorder grim tesseract slurp

# Appstream & Web libaries
install appstream-util libsoup3-devel

# end-4 quickshell features
install python-opencv plasma-nm kdialog bluedevil plasma-systemmonitor wtype matugen grimblast kde-material-you-colors mpvpaper ffmpeg

# Get theme assets that don't come as a rpm needed by end-4
## OneUI v4 (end-4 fork)
git clone https://github.com/end-4/OneUI4-Icons.git /tmp/oneui4-repo
copy-config "/tmp/oneui4-repo/OneUI" "${shared}/icons"
copy-config "/tmp/oneui4-repo/OneUI-dark" "${shared}/icons"
copy-config "/tmp/oneui4-repo/OneUI-light" "${shared}/icons"
rm -rf /tmp/oneui4-repo

## Gabarito fonts
git clone https://github.com/naipefoundry/gabarito.git /tmp/gabarito-font
mkdir "${shared}/fonts/gabarito-fonts"
mkdir "${shared}/licenses/gabarito-fonts"
copy-config /tmp/gabarito-font/fonts/ttf/Gabarito*.ttf "${shared}/fonts/gabarito-fonts"
copy-config "/tmp/gabarito-font/OFL.txt" "${shared}/fonts/gabarito-fonts"
fc-cache -fv

## MicroTeX (disabled because it breaks the anaconda installer)
# install cmake clang make
# git clone https://github.com/NanoMichael/MicroTeX.git /tmp/microtex-repo
# mkdir /tmp/microtex-repo/build
# cd /tmp/microtex-repo/build
# cmake ..
# make -j32
# mkdir -p "${shared}/factory/var/opt/MicroTeX"
# copy "/tmp/microtex-repo/build/LaTeX" "${shared}/factory/var/opt/MicroTeX"
# copy-config "/tmp/microtex-repo/build/res" "${shared}/factory/var/opt/MicroTeX"
# cd /

## Upscayl (disabled because it requires /opt which ublue has broken)
# wget -O /tmp/upscayl.rpm "$(curl -s https://api.github.com/repos/upscayl/upscayl/releases/latest | jq -r '.assets[] | select(.name | test("\\.rpm$")) | .browser_download_url')"
# install /tmp/upscayl.rpm

# Import the fedora end-4 dotfiles repository specifically for the installation process to modify.
echo "Patching end-4 dotfiles for default post-install."
git clone https://github.com/EisregenHaha/fedora-hyprland "${shared}/hypr/end-4_installer"

rm -f "${shared}/hypr/end-4_installer/fedora/fedora.sh"
rm -f "${shared}/hypr/end-4_installer/manual-install-helper.sh"
chmod +x "${patches}/"*
copy "${patches}/fedora.sh" "${shared}/hypr/end-4_installer/fedora/"
copy "${patches}/manual-install-helper.sh" "${shared}/hypr/end-4_installer/"

# Drop the repos as we dont need to keep them around anymore
drop atim/starship
drop deltacopy/darkly
