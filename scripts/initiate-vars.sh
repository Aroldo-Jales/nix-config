#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
VARS_FILE="${REPO_ROOT}/home/vars.nix"

prompt_default() {
  local prompt="$1"
  local default="$2"
  local out=""
  if [[ -n "$default" ]]; then
    read -r -p "${prompt} [${default}]: " out
    echo "${out:-$default}"
  else
    read -r -p "${prompt}: " out
    echo "$out"
  fi
}

sanitize_nix_string() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  echo "$s"
}

ensure_vars_nix() {
  if [[ -f "$VARS_FILE" ]]; then
    echo "OK: ${VARS_FILE} already exists (no action)."
    return 0
  fi

  echo "WARN: ${VARS_FILE} not found."
  echo "==> Creating ${VARS_FILE} (personal/private values)."

  local default_username="${SUDO_USER:-${USER:-}}"
  local username hostname homeDirectory fullName email nixConfigPath podmanSocket

  username="$(prompt_default "username" "$default_username")"
  if [[ -z "$username" ]]; then
    echo "ERROR: username cannot be empty."
    return 1
  fi

  hostname="$(prompt_default "hostname" "${username}-laptop")"
  homeDirectory="$(prompt_default "homeDirectory" "/home/${username}")"
  fullName="$(prompt_default "fullName" "")"
  email="$(prompt_default "email" "")"

  nixConfigPath="$(prompt_default "nixConfigPath" "${REPO_ROOT}")"
  podmanSocket="$(prompt_default "podmanSocket" "unix://\$XDG_RUNTIME_DIR/podman/podman.sock")"

  # sanitize
  username="$(sanitize_nix_string "$username")"
  hostname="$(sanitize_nix_string "$hostname")"
  homeDirectory="$(sanitize_nix_string "$homeDirectory")"
  fullName="$(sanitize_nix_string "$fullName")"
  email="$(sanitize_nix_string "$email")"
  nixConfigPath="$(sanitize_nix_string "$nixConfigPath")"
  podmanSocket="$(sanitize_nix_string "$podmanSocket")"

  local tmp
  tmp="$(mktemp)"

cat >"$tmp" <<EOF
let
  username = "${username}";
  hostname = "${hostname}";
  homeDirectory = "${homeDirectory}";
in {
  inherit username hostname homeDirectory;

  fullName = "${fullName}";
  email = "${email}";

  nixConfigPath = "${nixConfigPath}";
  podmanSocket = "${podmanSocket}";
}
EOF

  mkdir -p "$(dirname "$VARS_FILE")"
  echo "==> Saving ${VARS_FILE}..."
  install -m 0600 "$tmp" "$VARS_FILE"
  rm -f "$tmp"

  if command -v nix-instantiate >/dev/null 2>&1; then
    if ! nix-instantiate --parse "$VARS_FILE" >/dev/null; then
      echo "ERROR: Nix parse failed for ${VARS_FILE}."
      echo "Edit manually: ${VARS_FILE}"
      return 1
    fi
  fi

  echo "OK: created ${VARS_FILE}."
}

ensure_vars_nix
