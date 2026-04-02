#!/bin/bash
set -ouex pipefail
shopt -s expand_aliases
source /tmp/aliases.sh

skel="/etc/skel"
assets="/imageAssets"
shared="/usr/share"
system_services="/etc/systemd/system"

# Setup repositories
pacman-key --init
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Currently there is no possible way to swap kernels with a preserved initramfs.
# A fork is planned on arch-bootc specifically using cachyos-v3
# pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
# pacman-key --lsign-key F3B607488DB35A47
# pacman -U --noconfirm \
#     'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
#     'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst'
cat >> /etc/pacman.conf << 'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
# DISABLED DUE TO INITRAMFS ISSUE, see above regarding cachyos mirrorlist
# [cachyos]
# Include = /etc/pacman.d/cachyos-mirrorlist
# EOF

pacman -Sy --noconfirm

# Install build tools for AUR.
install base-devel git

# Build and install paru (AUR helper)
git clone https://aur.archlinux.org/paru.git /tmp/paru
attach # this makes the build user, enables use of open, wrap, and install-alt commands
open /tmp/paru
cd /tmp/paru
wrap makepkg -si --noconfirm
cd /

# DISABLED DUE TO INITRAMFS ISSUE, see above regarding cachyos mirrorlist
# Install CachyOS kernel (replaces default arch kernel)
# This is priority #1 to prevent packages breaking from below.
# we need to remove the vanilla kernel first, to prevent loss of the initramfs from dracut.
#install linux-cachyos linux-cachyos-headers

# Podman is missing in the base image as of march 19th, this corrects that.
install podman

# Install desktop shell
install-alt dms-shell-bin

# Install Hyprland and ecosystem
install hyprland xdg-desktop-portal-hyprland

# Install login manager
install greetd
# dms does not have a binary or stable package, we break the rule for now until they make one.
install-alt greetd-dms-greeter-git

# Install terminal and utils
install ghostty fastfetch
install adw-gtk-theme
install qt6ct-kde

# dank linux related utils
install dgop
install-alt dsearch-bin

# Configure user skeleton
add "${skel}/.config"
copy-config "${assets}/user.session/"* "${skel}/.config/"
copy-config "${assets}/setup.session/hyprland.setup.conf" "${shared}/hypr/"

# Configure greetd
greetd_skeleton="/etc/greetd"
add "${shared}/greetd"
copy "${greetd_skeleton}/config.toml" "${shared}/greetd/default-config.toml"
rm "${greetd_skeleton}/config.toml"
copy "${assets}/greetd.toml" "${greetd_skeleton}/config.toml"
copy "${assets}/greetd.session/session_registry.sh" "${greetd_skeleton}/session.sh"
scriptify "${greetd_skeleton}/session.sh"
#copy-config "${assets}/greetd.session/"* "${greetd_skeleton}/" this has been replaced by dms

# Setup post-install service to enable after
copy "${assets}/system.post/init.service" "${system_services}/sparrow-init.service"
copy "${assets}/system.post/init.sh" "${shared}/sparrow/postscripts/init.sh"
scriptify "${shared}/sparrow/postscripts/init.sh"

# Flatpak list goes into /etc because it should only exist on livecd experience
add "/etc/sparrow"
copy "${assets}/flatpak_list.toml" "/etc/sparrow/installation.flatpaks.toml"

# Remove AUR repos/helpers before enabling services (keep out of runtime)
drop paru
sed -i '/\[chaotic-aur\]/,/^$/d' /etc/pacman.conf
sed -i '/\[cachyos\]/,/^$/d' /etc/pacman.conf
detach # wrap and open will cease working here, installing and uninstalling packages from paru no longer becomes possible beyond here.
systemd-tmpfiles --clean # ensure that the detatched build user is removed from tmpfiles.

# DISABLED DUE TO INITRAMFS ISSUE, see above regarding cachyos mirrorlist
# pacman -Rs --noconfirm linux # this is required by bootc as only 1 kernel is allowed.

# # for some stupid reason, the vanilla kernel purges the initramfs entirely.
# # so we are simply regenerating it entirely, can we not delete someone else's initramfs please.
# KVER=$(ls /usr/lib/modules/ | grep cachyos | head -1)
# INITRAMFS="/boot/initramfs-${KVER}.img"
# if [[ -f "${INITRAMFS}" ]]; then
#     echo "Found existing initramfs: ${INITRAMFS}"
# else
#     echo "There is no initramfs present."
# fi
# echo "Regenerating initramfs for kernel: ${KVER}"
# dracut --force "${INITRAMFS}" "${KVER}"

# Enable services
insert greetd.service
insert sparrow-init.service
insert podman.socket
## dms cant be enabled because it is a user service, this requires to be set up in the user compositor.
# Requires to be enabled in post-install.
