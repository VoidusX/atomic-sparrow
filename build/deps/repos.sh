#!/bin/bash
echo "Installing Repositories."
include solopasha/hyprland
include errornointernet/quickshell
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
