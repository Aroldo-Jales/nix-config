#!/usr/bin/env bash

# This script runs for interactive shells via /etc/profile.d.
# It creates a container-local SSH directory with strict permissions
# and forces git/ssh to use it, avoiding "Bad owner or permissions"
# caused by host-mounted ~/.ssh inside distrobox.

SSH_SRC="${HOME}/.ssh"
SSH_DST="${HOME}/.ssh-container"

mkdir -p "${SSH_DST}" 2>/dev/null || true
chmod 700 "${SSH_DST}" 2>/dev/null || true

# Copy config/known_hosts if present (best-effort)
if [ -f "${SSH_SRC}/config" ]; then
  cp -f "${SSH_SRC}/config" "${SSH_DST}/config" 2>/dev/null || true
  chmod 600 "${SSH_DST}/config" 2>/dev/null || true
fi

if [ -f "${SSH_SRC}/known_hosts" ]; then
  cp -f "${SSH_SRC}/known_hosts" "${SSH_DST}/known_hosts" 2>/dev/null || true
  chmod 600 "${SSH_DST}/known_hosts" 2>/dev/null || true
fi

# Copy typical key files (best-effort)
for key in "${SSH_SRC}"/id_*; do
  [ -e "$key" ] || continue
  cp -f "$key" "${SSH_DST}/" 2>/dev/null || true
done

chmod 600 "${SSH_DST}"/id_* 2>/dev/null || true
chmod 644 "${SSH_DST}"/id_*.pub 2>/dev/null || true

touch "${SSH_DST}/known_hosts" 2>/dev/null || true
chmod 600 "${SSH_DST}/known_hosts" 2>/dev/null || true

# Force git to use the container-local SSH config + known_hosts
export GIT_SSH_COMMAND="ssh -F ${SSH_DST}/config -o UserKnownHostsFile=${SSH_DST}/known_hosts"

# Optional: make manual `ssh` also use the container config in interactive shells
case "$-" in
  *i*) alias ssh="ssh -F ${SSH_DST}/config -o UserKnownHostsFile=${SSH_DST}/known_hosts" ;;
esac
