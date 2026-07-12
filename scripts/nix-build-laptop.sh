#!/usr/bin/env bash
set -euo pipefail

# Repository root
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Target host
HOST="laptop"

# Hardware paths
TARGET_DIR="hosts/${HOST}"
TARGET_HW="${TARGET_DIR}/hardware-configuration.nix"

# Vars init script
INIT_VARS_SCRIPT="${REPO_ROOT}/scripts/initiate-vars.sh"


# -------------------------
# Vars check
# -------------------------

ensure_vars() {
  if [[ ! -x "$INIT_VARS_SCRIPT" ]]; then
    echo "ERROR: scripts/initiate-vars.sh not found or not executable:"
    echo "  $INIT_VARS_SCRIPT"
    echo
    echo "Run:"
    echo "  chmod +x scripts/initiate-vars.sh"
    exit 1
  fi

  echo "==> Checking vars.nix..."
  "$INIT_VARS_SCRIPT"
}


# -------------------------
# Hardware check (generate locally)
# -------------------------

ensure_hw_config() {
  if [[ -f "$TARGET_HW" ]]; then
    echo "OK: ${TARGET_HW} already exists (no action)."
    return 0
  fi

  echo "WARN: ${TARGET_HW} not found."
  echo "==> Generating hardware-configuration.nix into ${TARGET_HW}..."

  mkdir -p "$TARGET_DIR"

  # Generate ONLY hardware config (does not touch configuration.nix)
  sudo nixos-generate-config --show-hardware-config > "$TARGET_HW"

  # Ensure file is owned by the current user (repo file), readable by all
  sudo chown "$(id -u):$(id -g)" "$TARGET_HW"
  chmod 644 "$TARGET_HW"

  echo "OK: generated ${TARGET_HW}."
}


# -------------------------
# Prerequisites
# -------------------------

ensure_prereqs() {
  ensure_vars
  ensure_hw_config
}


# -------------------------
# Actions
# -------------------------

do_switch() {
  ensure_prereqs
  echo "==> nixos-rebuild switch --flake ${REPO_ROOT}#${HOST} --impure"
  sudo nixos-rebuild switch --flake "${REPO_ROOT}#${HOST}" --impure
}

do_boot() {
  ensure_prereqs
  echo "==> nixos-rebuild boot --flake ${REPO_ROOT}#${HOST} --impure"
  sudo nixos-rebuild boot --flake "${REPO_ROOT}#${HOST}" --impure
}

do_build() {
  ensure_prereqs
  echo "==> nixos-rebuild build --flake ${REPO_ROOT}#${HOST} --impure"
  sudo nixos-rebuild build --flake "${REPO_ROOT}#${HOST}" --impure
}

do_update_and_switch() {
  ensure_prereqs

  echo "==> nix flake update"
  nix flake update

  echo "==> nixos-rebuild switch --flake ${REPO_ROOT}#${HOST} --impure"
  sudo nixos-rebuild switch --flake "${REPO_ROOT}#${HOST}" --impure
}


# -------------------------
# UI
# -------------------------

show_paths() {
  echo "Repo:         $REPO_ROOT"
  echo "Host:         $HOST"
  echo "Target HW:    $TARGET_HW"
  echo "Vars script:  $INIT_VARS_SCRIPT"
}

menu() {
  echo
  echo "========== nix-build (${HOST}) =========="
  echo "1) Check/generate hardware-configuration.nix (if missing)"
  echo "2) nixos-rebuild SWITCH"
  echo "3) nixos-rebuild BOOT"
  echo "4) nixos-rebuild BUILD"
  echo "5) nix flake update + nixos-rebuild switch"
  echo "6) Show paths"
  echo "0) Exit"
  echo "========================================="
  printf "Choose: "
}


# -------------------------
# Main loop
# -------------------------

while true; do
  menu
  read -r choice

  case "$choice" in
    1)
      ensure_prereqs
      ;;
    2)
      do_switch
      ;;
    3)
      do_boot
      ;;
    4)
      do_build
      ;;
    5)
      do_update_and_switch
      ;;
    6)
      show_paths
      ;;
    0)
      echo "Exit."
      exit 0
      ;;
    *)
      echo "Invalid choice: $choice"
      ;;
  esac
done
