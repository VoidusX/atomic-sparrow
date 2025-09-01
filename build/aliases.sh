#!/bin/bash

alias load-repos='source /deps/repos.sh'
alias add-hyprland="source /deps/hypr.sh"
alias add-regreet="source /deps/regreet.sh"
alias add-installer="source /deps/installer.sh"
alias modify-regreet="source /tmp/opt/regreet.theme.sh"
alias modify-hyprland-default="source /tmp/opt/hyprland.theme.sh"
alias populate-hyprland-default="source /tmp/opt/hyprland.pkgs.sh"


alias install="dnf5 -y install"
alias include="dnf5 -y copr enable"
alias drop="dnf5 -y copr disable"
alias insert="systemctl enable"

alias copy="cp" # This is intended for asset files, it should be the same as normal cp
alias copy-config="cp -r" # Same as above for directories.
alias add="mkdir -p" # Create a directory easily
alias fetch="wget -q" # Fetch a file easily
