image_name := env("IMAGE_NAME", "atomic-sparrow")
image_tag := env("DEFAULT_TAG", "latest")
image_registry := env("IMAGE_REGISTRY", "ghcr.io")

base_dir := env("BUILD_BASE_DIR", ".")
filesystem := env("BUILD_FILESYSTEM", "ext4")
selinux := env("BUILD_SELINUX", "true")

ci := env("CI", "false")
tag := env("TAG", image_tag)
platform := env("PLATFORM", env("RUNNER_ARCH", "arm64"))

options := if selinux == "true" { "-v /var/lib/containers:/var/lib/containers:Z -v /etc/containers:/etc/containers:Z -v /sys/fs/selinux:/sys/fs/selinux --security-opt label=type:unconfined_t" } else { "-v /var/lib/containers:/var/lib/containers -v /etc/containers:/etc/containers" }
container_runtime := env("CONTAINER_RUNTIME", `command -v podman >/dev/null 2>&1 && echo podman || echo docker`)

build-containerfile $image_name=image_name:
    sudo {{container_runtime}} build -f Containerfile -t "${image_name}:latest" .

bootc *ARGS:
    sudo {{container_runtime}} run \
        --rm --privileged --pid=host \
        -it \
        {{options}} \
        -v /dev:/dev \
        -e RUST_LOG=debug \
        -v "{{base_dir}}:/data" \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    if [[ "{{ci}}" == "true" ]]; then
        CI_REGISTRY_LOWER=$(echo "{{image_registry}}" | tr '[:upper:]' '[:lower:]')
        CI_NAME_LOWER=$(echo "{{image_name}}" | tr '[:upper:]' '[:lower:]')
        CI_IMAGE="${CI_REGISTRY_LOWER}/${CI_NAME_LOWER}:{{tag}}"
        echo "Pulling CI image: ${CI_IMAGE} with arch: linux/${platform}"
        sudo {{container_runtime}} pull --platform "linux/{{platform}}" "${CI_IMAGE}" || true
    else
        CI_IMAGE="{{image_name}}:latest"
    fi

    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 20G "${base_dir}/bootable.img"
    fi
    sudo {{container_runtime}} run \
        --rm --privileged --pid=host \
        {{options}} \
        -v /dev:/dev \
        -e RUST_LOG=debug \
        -v "{{base_dir}}:/data" \
        "${CI_IMAGE}" bootc install to-disk --composefs-backend --via-loopback /data/bootable.img --filesystem "{{filesystem}}" --wipe --bootloader systemd

build-qcow2 $base_dir=base_dir:
    #!/usr/bin/env bash
    just generate-bootable-image
    qemu-img convert -O qcow2 "${base_dir}/bootable.img" "${base_dir}/sparrow.qcow2"

build-raw $base_dir=base_dir:
    #!/usr/bin/env bash
    just generate-bootable-image
    cp "${base_dir}/bootable.img" "${base_dir}/sparrow.raw"

build-iso $base_dir=base_dir:
    #!/usr/bin/env bash
    just generate-bootable-image
    mkdir -p "${base_dir}/mnt"
    sudo mount -o loop "${base_dir}/bootable.img" "${base_dir}/mnt"
    sudo mkisofs -o "${base_dir}/sparrow.iso" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table "${base_dir}/mnt"
    sudo umount "${base_dir}/mnt"
