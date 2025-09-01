#!/bin/bash

echo "Installing local packages. - sparrow-installer"
# Get necessary stuff to prepare to build.
export CARGO_HOME="/tmp/.cargo"
add /tmp/sparrow-installer/
add /tmp/sparrow-installer/repo
git clone --depth 1 https://github.com/VoidusX/sparrow-installer.git /tmp/sparrow-installer/repo
cd /tmp/sparrow-installer/repo

# Build the installer to put into the atomic image.
cargo build --release
cp target/release/sparrow-installer /usr/bin
cd /
