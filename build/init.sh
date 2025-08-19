#!/bin/bash

# Initial Setup
set -ouex pipefail
shopt -s expand_aliases
source /tmp/aliases.sh

# Variables
skel="/etc/skel"
assets="/imageAssets"
shared="/usr/share"

echo "Assets to load in:"
ls -h -N "${assets}"
ls -h -N -la "${assets}"/greetd.session/
ls -h -N -la "${assets}"/user.session/

### Install packages
# RPMfusion repos are available by default in ublue main images
# Our build script flows via step sources.
load-repos
add-hyprland
add-regreet
modify-regreet

# Set our default skeleton data for new user (They need to set up end-4 dotfiles)
add "${skel}/.config"
copy-config "${assets}/user.session/"* "${skel}/.config/"
copy-config "${assets}/setup.session/hyprland.setup.conf" "${shared}/hypr/"

# Enabling services not bound to build components
insert podman.socket
