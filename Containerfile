# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS builder
COPY build /

# Isolate assets as a reference for build scripts, only copying what is necessary.
FROM scratch AS assets
COPY assets /

# Base Image
FROM ghcr.io/ublue-os/base-main:latest

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
#
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=assets,source=/,target=/assets \
    --mount=type=bind,from=builder,source=/,target=/builder \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    cp /builder/aliases.sh /tmp/ && \
    mkdir -p /image-assets && cp -r /assets/* /image-assets/ && \
    mkdir -p /deps && cp -r /builder/deps/* /deps/ && \
    mkdir -p /tmp/opt && cp -r /builder/opt/* /tmp/opt/ && \
    /builder/init.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
