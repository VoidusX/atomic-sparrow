#!/bin/bash

echo "Preparing Regreet."
# Get necessary stuff to prepare to build.
add /tmp/.cargo
export CARGO_HOME="/tmp/.cargo"
install tmux jq cargo gtk4-devel python3-pip greetd
add /tmp/regreet/
add /tmp/regreet/repo
fetch 'https://api.github.com/repos/rharish101/ReGreet/releases/latest' -O '/tmp/regreet/data'
regreet_metadata=$(cat /tmp/regreet/data)
regreet_version=$(echo "$regreet_metadata" | jq '.name' | tr -d '"')
fetch "https://api.github.com/repos/rharish101/ReGreet/tarball/$regreet_version" -O '/tmp/regreet/repo.tar.gz'
tar -xvf /tmp/regreet/repo.tar.gz -C /tmp/regreet/repo --strip-components=1
cd /tmp/regreet/repo

echo "Installing Regreet."
# Build the regreet package so we can install it.
cargo build -F gtk4_8 --release
cp target/release/regreet /usr/bin
cd /

insert greetd.service
