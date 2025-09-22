#!/usr/bin/env bash
set -euo pipefail

REGISTRY="docker.io"
IMAGE="bensuperpc/cc65"
TAG="1.0.0-debian"

DOCKER_IMAGE="cc65-$(uuidgen)"

CPUS="$(nproc --all)"
CPU_SHARES="1024"
RES_RAM="4GB"
MAX_RAM="16GB"
TMPFS_SIZE="4g"

PUID="$(id -u)"
PGID="$(id -g)"
USERNAME="$(id -un)"

docker run --rm \
        --security-opt no-new-privileges --read-only --cap-drop SYS_ADMIN -e PUID="$PUID" -e PGID="$PGID" -e USERNAME="$USERNAME" \
        --mount type=bind,source=$(pwd),target=/work --workdir /work \
        --mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$TMPFS_SIZE \
        --platform linux/amd64 \
        --cpus "$CPUS" --cpu-shares "$CPU_SHARES" --memory-reservation "$RES_RAM" --memory "$MAX_RAM" \
        --name "$DOCKER_IMAGE" \
        "$REGISTRY/$IMAGE:$TAG" \
        "$@"
