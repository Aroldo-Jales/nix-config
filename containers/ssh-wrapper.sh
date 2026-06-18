#!/usr/bin/env bash
set -euo pipefail

USER_HOME="/home/aroldoljs"
SSH_CFG="${USER_HOME}/.ssh-container/config"
KNOWN_HOSTS="${USER_HOME}/.ssh-container/known_hosts"
KEY_FILE="${USER_HOME}/.ssh-container/id_ed25519_github"

if [[ -f "$SSH_CFG" ]]; then
  exec /usr/bin/ssh \
    -F "$SSH_CFG" \
    -o "UserKnownHostsFile=$KNOWN_HOSTS" \
    -o "IdentitiesOnly=yes" \
    -o "IdentityFile=$KEY_FILE" \
    "$@"
fi

exec /usr/bin/ssh "$@"
