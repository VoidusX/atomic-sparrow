#!/bin/bash

# Initial Setup
set -ouex pipefail
shopt -s expand_aliases
source /tmp/aliases.sh

# Variables
skel="/etc/skel"
assets="/image-assets"
shared="/usr/share"

### Install packages
# RPMfusion repos are available by default in ublue main images

# Our build script flows via step sources.
load-repos
add-hyprland
add-regreet
modify-regreet

# Set our default skeleton data for new user (They need to set up end-4 dotfiles)
add "${skel}/.config"
copy-config "${assets}/user.session/*" "${skel}/.config/"

# Enabling services not bound to build components
insert podman.socket
