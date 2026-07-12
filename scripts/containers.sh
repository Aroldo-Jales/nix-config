#!/usr/bin/env bash
set -euo pipefail

# containers.sh (simple)
# - Reads ./containers/*/Dockerfile
# - Lets you build an image + create a distrobox for a selected profile
# - Lets you enter the distrobox
# - Lets you REMOVE only that profile's container + image + its named volumes (no global volume prune)

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

CONTAINERS_DIR="${REPO_ROOT}/containers"

have_cmd() { command -v "$1" >/dev/null 2>&1; }
die() { echo "ERROR: $*" >&2; exit 1; }
pause() { read -r -p "Press Enter to continue..." _; }

ensure_prereqs() {
  [[ -d "$CONTAINERS_DIR" ]] || die "containers directory not found: $CONTAINERS_DIR"
  have_cmd podman || die "podman not found."
  have_cmd distrobox-create || die "distrobox-create not found."
  have_cmd distrobox-enter || die "distrobox-enter not found."
}

# -------- Profile discovery --------

PROFILES=()
PATHS=()

list_profiles() {
  PROFILES=()
  PATHS=()

  local d name
  for d in "$CONTAINERS_DIR"/*; do
    [[ -d "$d" ]] || continue
    [[ -f "$d/Dockerfile" ]] || continue
    name="$(basename "$d")"
    PROFILES+=("$name")
    PATHS+=("$d")
  done

  if [[ ${#PROFILES[@]} -eq 0 ]]; then
    echo "No profiles found under: $CONTAINERS_DIR"
    return 1
  fi

  echo
  echo "Profiles found in ./containers:"
  echo "-----------------------------"
  local i=1
  for name in "${PROFILES[@]}"; do
    printf "%2d) %s\n" "$i" "$name"
    ((i++))
  done
  echo "-----------------------------"
}

SELECTED_NAME=""
SELECTED_DIR=""

select_profile() {
  list_profiles || return 1

  local choice=""
  while true; do
    read -r -p "Select a profile (number) or 0 to cancel: " choice
    if [[ "$choice" == "0" ]]; then
      return 1
    fi
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#PROFILES[@]} )); then
      SELECTED_NAME="${PROFILES[$((choice-1))]}"
      SELECTED_DIR="${PATHS[$((choice-1))]}"
      return 0
    fi
    echo "Invalid selection."
  done
}

# -------- Naming rules --------
# Default image tag: <profile>:latest
# Default distrobox/container name: <profile>

image_tag_for() { echo "${1}:latest"; }
distrobox_name_for() { echo "${1}"; }

# -------- Podman helpers --------

image_exists() { podman image exists "$1" >/dev/null 2>&1; }
container_exists() { podman container exists "$1" >/dev/null 2>&1; }

build_image() {
  local tag="$1"

  # Build context must be the repo root so Dockerfile can COPY shared files like:
  #   COPY scripts/containers/fix-ssh-runtime.sh /usr/local/bin/fix-ssh-runtime.sh
  # Using "$SELECTED_DIR" as context would block COPY of ../ files (context escape).
  local context_dir="$REPO_ROOT"
  local dockerfile_path="$SELECTED_DIR/Dockerfile"

  echo "==> Building image: $tag"
  echo "    Dockerfile: $dockerfile_path"
  echo "    Context:    $context_dir"

  podman build \
    -t "$tag" \
    -f "$dockerfile_path" \
    "$context_dir"

  echo "OK: built $tag"
}

create_distrobox() {
  local tag="$1"
  local dbx="$2"

  if container_exists "$dbx"; then
    echo "OK: distrobox container already exists: $dbx"
    return 0
  fi

  echo "==> Creating distrobox: $dbx (from $tag)"
  distrobox-create \
    --name "$dbx" \
    --image "$tag" \
    --home "$HOME" \
    --additional-packages "bash-completion" \
    --additional-flags "--userns=keep-id"
  echo "OK: created $dbx"
}

enter_distrobox() {
  local dbx="$1"
  if ! container_exists "$dbx"; then
    echo "ERROR: distrobox container does not exist: $dbx"
    echo "Use 'Create' first."
    return 1
  fi
  echo "==> Entering distrobox: $dbx"
  distrobox-enter "$dbx"
}

ensure_build_and_create() {
  local tag="$1"
  local dbx="$2"

  if ! image_exists "$tag"; then
    build_image "$tag"
  else
    echo "OK: image exists: $tag"
  fi

  create_distrobox "$tag" "$dbx"
}

# -------- Removal (only for selected profile) --------
# Removes:
# - the podman container used by distrobox (same name)
# - the image tag for that profile
# - ONLY the named volumes attached to that container (no global prune)
# Then does:
# - safe dangling image prune

remove_profile_artifacts() {
  local profile="$1"
  local tag dbx
  tag="$(image_tag_for "$profile")"
  dbx="$(distrobox_name_for "$profile")"

  echo
  echo "==> Removing artifacts for profile: $profile"
  echo "    Container/distrobox: $dbx"
  echo "    Image tag:           $tag"
  echo

  if ! container_exists "$dbx" && ! image_exists "$tag"; then
    echo "Nothing to remove (container and image are missing)."
    return 0
  fi

  # Capture ONLY named volumes attached to the container (if present)
  local vols=()
  if container_exists "$dbx"; then
    mapfile -t vols < <(
      podman inspect -f '{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}}{{"\n"}}{{end}}{{end}}' "$dbx" 2>/dev/null \
        | awk 'NF{print}' | sort -u
    )
  fi

  # Remove container (force)
  if container_exists "$dbx"; then
    echo "==> Removing container: $dbx"
    podman rm -f "$dbx" || true
    echo "OK: container removed."
  else
    echo "OK: container not found."
  fi

  # Remove image for this profile
  if image_exists "$tag"; then
    echo "==> Removing image: $tag"
    podman rmi -f "$tag" || true
    echo "OK: image removed."
  else
    echo "OK: image not found."
  fi

  # Remove only volumes that were attached to that container
  if [[ ${#vols[@]} -gt 0 ]]; then
    echo "==> Removing named volumes attached to '$dbx':"
    printf '  - %s\n' "${vols[@]}"
    podman volume rm -f "${vols[@]}" || true
    echo "OK: volumes removed (best-effort)."
  else
    echo "OK: no named volumes found for this container."
  fi

  # Safe cleanup: dangling images/layers only
  echo "==> Pruning dangling images (safe)..."
  podman image prune -f >/dev/null 2>&1 || true
  echo "OK: dangling image prune done."

  echo "Done."
}

# -------- UI --------

menu() {
  echo
  echo "====== Containers (simple) ======"
  echo "1) List profiles"
  echo "2) Create (build image if missing + create distrobox)"
  echo "3) Enter distrobox"
  echo "4) Remove (container | image + volumes)"
  echo "0) Exit"
  echo "================================="
  printf "Choose: "
}

# -------- Main --------

ensure_prereqs

while true; do
  menu
  read -r choice

  case "${choice:-}" in
    1)
      list_profiles || true
      pause
      ;;
    2)
      if select_profile; then
        TAG="$(image_tag_for "$SELECTED_NAME")"
        DBX="$(distrobox_name_for "$SELECTED_NAME")"
        echo
        echo "Selected:  $SELECTED_NAME"
        echo "Image:     $TAG"
        echo "Distrobox: $DBX"
        ensure_build_and_create "$TAG" "$DBX"
      fi
      pause
      ;;
    3)
      if select_profile; then
        DBX="$(distrobox_name_for "$SELECTED_NAME")"
        enter_distrobox "$DBX"
      fi
      ;;
    4)
      if select_profile; then
        echo
        echo "WARNING: This will remove ONLY the selected profile's container/image/volumes."
        echo "Selected: ${SELECTED_NAME}"
        read -r -p "Type 'delete' to confirm: " confirm
        if [[ "$confirm" == "delete" ]]; then
          remove_profile_artifacts "$SELECTED_NAME"
        else
          echo "Canceled."
        fi
      fi
      pause
      ;;
    0)
      echo "Exit."
      exit 0
      ;;
    *)
      echo "Invalid choice: ${choice:-}"
      pause
      ;;
  esac
done
