#!/bin/bash
alias wrap="runuser -u oci-build --"
alias open="chown -R oci-build:oci-build"
alias install="pacman -S --noconfirm"
alias install-alt="paru -S --noconfirm --skipreview"
alias drop="pacman -Rdd --noconfirm"
alias insert="systemctl enable"

alias copy="cp"
alias copy-config="cp -r"
alias add="mkdir -p"
