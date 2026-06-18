#!/usr/bin/env bash
set -euo pipefail

VARS_ETC="/etc/nixos/vars.nix"

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
  if [[ -f "$VARS_ETC" ]]; then
    echo "OK: ${VARS_ETC} already exists (no action)."
    return 0
  fi

  echo "WARN: ${VARS_ETC} not found."
  echo "==> Creating ${VARS_ETC} (personal/private values)."

  local default_username="${SUDO_USER:-${USER:-}}"
  local username hostname fullName email nixConfigPath podmanSocket

  username="$(prompt_default "username" "$default_username")"
  if [[ -z "$username" ]]; then
    echo "ERROR: username cannot be empty."
    return 1
  fi

  hostname="$(prompt_default "hostname" "${username}-laptop")"
  fullName="$(prompt_default "fullName" "")"
  email="$(prompt_default "email" "")"

  nixConfigPath="$(prompt_default "nixConfigPath" "/home/${username}/nix-config")"
  podmanSocket="$(prompt_default "podmanSocket" "unix://\$XDG_RUNTIME_DIR/podman/podman.sock")"

  # sanitize
  username="$(sanitize_nix_string "$username")"
  hostname="$(sanitize_nix_string "$hostname")"
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
in {
  inherit username;

  fullName = "${fullName}";
  email = "${email}";

  nixConfigPath = "${nixConfigPath}";
  podmanSocket = "${podmanSocket}";
}
EOF

  echo "==> Saving ${VARS_ETC} (root-owned, 0644)..."
  sudo install -m 0644 -o root -g root "$tmp" "$VARS_ETC"
  rm -f "$tmp"

  if command -v nix-instantiate >/dev/null 2>&1; then
    if ! sudo nix-instantiate --parse "$VARS_ETC" >/dev/null; then
      echo "ERROR: Nix parse failed for ${VARS_ETC}."
      echo "Edit manually: sudoedit ${VARS_ETC}"
      return 1
    fi
  fi

  echo "OK: created ${VARS_ETC}."
}

ensure_vars_nix