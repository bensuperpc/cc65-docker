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

ARCHIVE_PATH="$1"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
    echo "Erreur : le fichier '$ARCHIVE_PATH' n'existe pas."
    exit 1
fi

zstd -d -c "$ARCHIVE_PATH" | docker load
