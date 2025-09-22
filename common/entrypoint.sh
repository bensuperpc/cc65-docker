#!/usr/bin/env bash
set -euo pipefail

PUID=${PUID:-0}
PGID=${PGID:-0}
USERNAME=${USERNAME:-myuser}
PRE_CMD_EXEC=${PRE_CMD_EXEC:-""}
USER_CMD_EXEC=${USER_CMD_EXEC:-""}

if [ -n "$PRE_CMD_EXEC" ]; then
    echo "[entrypoint] Running pre command: $PRE_CMD_EXEC"
    bash -c "$PRE_CMD_EXEC"
fi

if [ "$PUID" -ne 0 ] || [ "$PGID" -ne 0 ]; then
    if ! getent group "$PGID" >/dev/null; then
        echo "[entrypoint] Group with GID $PGID does not exist, creating group $USERNAME"
        groupadd -g "$PGID" "$USERNAME"
    fi
    if ! id -u "$USERNAME" >/dev/null 2>&1; then
        if getent passwd "$PUID" >/dev/null; then
            echo "[entrypoint] UID $PUID already exists. Using existing user."
            USERNAME=$(getent passwd "$PUID" | cut -d: -f1)
        else
            echo "[entrypoint] User with UID $PUID does not exist, creating user $USERNAME"
            useradd -u "$PUID" -g "$PGID" -m -s /bin/bash "$USERNAME"
        fi
    else
        echo "[entrypoint] User $USERNAME already exists, updating UID and GID"
        usermod -u "$PUID" -g "$PGID" "$USERNAME"
    fi
fi

if [[ -n $USER_CMD_EXEC ]]; then
    echo "[entrypoint] User-hook: $USER_CMD_EXEC"
    if [ "$PUID" -ne 0 ] || [ "$PGID" -ne 0 ]; then
        bash -c "$USER_CMD_EXEC"
    else
        gosu "$USERNAME" bash -c "$USER_CMD_EXEC"
    fi
fi

if [ "$PUID" -ne 0 ] || [ "$PGID" -ne 0 ]; then
    echo "[entrypoint] Running user command as $USERNAME: $@"
    exec gosu "$USERNAME" bash -c "$@"
else
    echo "[entrypoint] Running as root user"
    exec bash -c "$@"
fi
