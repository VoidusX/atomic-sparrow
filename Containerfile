# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS builder
COPY build /
COPY .luaurc /

# Isolate assets as a reference for build scripts, only copying what is necessary.
FROM scratch AS assets
COPY assets /

# Base Image (Arch-based bootc)
# arch-bootc handles bootc integration, ostree, and base system setup
#FROM ghcr.io/bootcrew/arch-bootc:latest

# Base Image (UBlue-based bootc)
FROM ghcr.io/ublue-os/base-main:latest

## Other possible base images include:
# CachyOS bootc image (when available)
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.
RUN rm /opt && mkdir /opt



### MODIFICATIONS
## Install packages and configure the system

RUN --mount=type=bind,from=assets,source=/,target=/assets \
    --mount=type=bind,from=builder,source=/,target=/builder \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    mkdir -p /imageAssets && cp -r /assets/* /imageAssets/ && \
    dnf5 install -y bsdtar && \
    curl -L -o /tmp/lune.zip https://github.com/lune-org/lune/releases/download/v0.10.5/lune-0.10.5-linux-x86_64.zip && \
    bsdtar -xf /tmp/lune.zip -C /tmp && \
    find /tmp -name "lune" -type f -executable -exec mv {} /usr/bin/lune \; && \
    chmod +x /usr/bin/lune && \
    lune run /builder/init.luau

# https://bootc-dev.github.io/bootc/bootc-images.html#standard-metadata-for-bootc-compatible-images
LABEL containers.bootc 1

RUN bootc container lint
