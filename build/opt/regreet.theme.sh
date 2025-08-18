#!/bin/bash

# Variables
assets="/image-assets"
greetd_skeleton="/etc/greetd"
shared="/usr/share"

echo "Installing Regreet Theme."
# Our configuration relies on a third party theme not in COPR or fedora packages.
fetch https://github.com/dracula/gtk/archive/master.zip -O /tmp/regreet/theme.zip
unzip /tmp/regreet/theme.zip -d /usr/share/themes/

echo "Configuring Regreet."
add "${shared}/greetd"
copy "${greetd_skeleton}/config.toml ${shared}/greetd/default-config.toml"
rm "${shared}/greetd/config.toml"
copy "${assets}/greetd.toml ${greetd_skeleton}/config.toml"
copy-config "${assets}/greetd.session/* ${greetd_skeleton}/"
