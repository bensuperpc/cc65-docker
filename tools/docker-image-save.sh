#!/usr/bin/env bash
set -euo pipefail
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Script, 2020                                            //
#//  Author: Bensuperpc                                      //
#//  Created: 21, November, 2020                             //
#//  Modified: 08, October, 2023                             //
#//  file: -                                                 //
#//                                                          //
#//  Source: -                                               //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

if (( $# ==  0)); then
    echo "Usage: ${0##*/} <docker image>"
    exit 1
fi

DOCKER_IMAGE="$1"
OUTPUT_PATH="${DOCKER_IMAGE}.tar.zst"
mkdir -p "$(dirname "$OUTPUT_PATH")"
docker pull "$DOCKER_IMAGE"
# --max
docker save "$DOCKER_IMAGE" | zstd -z -v -T0 --ultra -22 > "$OUTPUT_PATH"
