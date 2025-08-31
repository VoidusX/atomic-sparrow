#!/bin/bash
echo "Installing Repositories."
include solopasha/hyprland
include errornointernet/quickshell
# include atim/starship
# include deltacopy/darkly
# dnf5 -y config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:luisbocanegra/Fedora_42/home:luisbocanegra.repo --overwrite
# this is being used for a package that requires python, but anaconda installer breaks with python installed.
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
