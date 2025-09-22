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

if (( $# == 0 )); then
    echo "Usage: ${0##*/} <docker volume>"
    exit 1
fi

DOCKER_VOLUME="$1"
INPUT_PATH="${DOCKER_VOLUME}.tar.zst"

if [ ! -f "$INPUT_PATH" ]; then
    echo "Error: File '$INPUT_PATH' not found."
    exit 1
fi

docker run --rm \
    --volume "$DOCKER_VOLUME":/volume1 \
    --volume "$(pwd)":/backup \
    alpine:latest sh -c "apk add --no-cache zstd tar && \
    tar xvf '/backup/$INPUT_PATH' -C /volume1"
