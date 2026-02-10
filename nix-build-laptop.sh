#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

HOST="laptop"
TARGET_DIR="hosts/${HOST}"
TARGET_HW="${TARGET_DIR}/hardware-configuration.nix"

SRC_ETC="/etc/nixos/hardware-configuration.nix"
SRC_ETC_HOST="/etc/nixos/hosts/${HOST}/hardware-configuration.nix"

ensure_hw_config() {
  if [[ -f "$TARGET_HW" ]]; then
    echo "OK: ${TARGET_HW} already exists (no action)."
    return 0
  fi

  echo "WARN: ${TARGET_HW} not found."
  echo "==> Try copy from /etc/nixos..."

  mkdir -p "$TARGET_DIR"

  if [[ -f "$SRC_ETC" ]]; then
    sudo cp -v "$SRC_ETC" "$TARGET_HW"
  elif [[ -f "$SRC_ETC_HOST" ]]; then
    sudo cp -v "$SRC_ETC_HOST" "$TARGET_HW"
  else
    echo "ERRO: hardware-configuration.nix not found:"
    echo "  - $SRC_ETC"
    echo "  - $SRC_ETC_HOST"
    echo
    echo "Generate with: sudo nixos-generate-config"
    return 1
  fi

  sudo chown "$(id -u):$(id -g)" "$TARGET_HW"
  chmod 644 "$TARGET_HW"
  echo "OK: copiado para ${TARGET_HW}."
}

do_switch() {
  ensure_hw_config
  echo "==> nixos-rebuild switch --flake .#${HOST}"
  sudo nixos-rebuild switch --flake ".#${HOST}"
}

do_boot() {
  ensure_hw_config
  echo "==> nixos-rebuild boot --flake .#${HOST}"
  sudo nixos-rebuild boot --flake ".#${HOST}"
}

do_build() {
  ensure_hw_config
  echo "==> nixos-rebuild build --flake .#${HOST}"
  sudo nixos-rebuild build --flake ".#${HOST}"
}

do_update_and_switch() {
  ensure_hw_config
  echo "==> nix flake update"
  nix flake update
  echo "==> nixos-rebuild switch --flake .#${HOST}"
  sudo nixos-rebuild switch --flake ".#${HOST}"
}

show_paths() {
  echo "Repo:         $REPO_ROOT"
  echo "Host:         $HOST"
  echo "Target HW:    $TARGET_HW"
  echo "Src HW 1:     $SRC_ETC"
  echo "Src HW 2:     $SRC_ETC_HOST"
}

menu() {
  echo
  echo "========== nix-build (${HOST}) =========="
  echo "1) Check/copy hardware-configuration.nix (if missing)"
  echo "2) nixos-rebuild SWITCH"
  echo "3) nixos-rebuild BOOT"
  echo "4) nixos-rebuild BUILD"
  echo "5) nix flake update + nixos-rebuild switch"
  echo "6) Show paths"
  echo "0) Exit"
  echo "========================================="
  printf "Choose: "
}

while true; do
  menu
  read -r choice

  case "$choice" in
    1)
      ensure_hw_config
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