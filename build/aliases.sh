#!/bin/bash
builduser="oci-build"
buildperm="${builduser} ALL=(ALL) NOPASSWD: ALL"

alias wrap="runuser -u ${builduser} --"
alias open="chown -R ${builduser}:${builduser}"
alias attach="useradd -m -s /bin/bash ${builduser} && echo '${buildperm}' | tee -a /etc/sudoers"
alias detach="grep -v '${buildperm}' /etc/sudoers | tee /etc/sudoers && userdel ${builduser}"

alias install="pacman -S --noconfirm"
alias install-alt="wrap paru -S --noconfirm --skipreview"
alias drop="pacman -Rdd --noconfirm"
alias insert="systemctl enable"

alias copy="cp"
alias copy-config="cp -r"
alias add="mkdir -p"
alias scriptify="chmod +x"

echo "attach command does the following: useradd -m -s /bin/bash ${builduser} && echo '${buildperm}' | tee -a /etc/sudoers"
echo "detach command does the following: grep -v '${buildperm}' /etc/sudoers | tee /etc/sudoers && userdel ${builduser}"
