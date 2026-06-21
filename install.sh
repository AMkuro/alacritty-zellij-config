#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [--dry-run]

Symlinks config directories under .config/ into ~/.config/.
Existing paths are replaced only after confirmation, and are backed up
with .bak.YYYYmmdd-HHMMSS before replacement.
This script does not require sudo.
EOF
}

confirm_replace() {
  local dst="$1"
  local reply

  if [[ ! -t 0 ]]; then
    echo "ERROR: Existing path requires confirmation: $dst" >&2
    echo "Run this script from an interactive shell." >&2
    return 1
  fi

  read -r -p "Replace existing $dst with a symlink? [y/N] " reply
  [[ "$reply" == "y" || "$reply" == "Y" || "$reply" == "yes" || "$reply" == "YES" ]]
}

while (($# > 0)); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

config_dirs=(
  ".config/alacritty"
  ".config/zellij"
)

for rel_path in "${config_dirs[@]}"; do
  src="$REPO_ROOT/$rel_path"
  dst="$HOME/$rel_path"

  if [[ ! -d "$src" ]]; then
    echo "ERROR: Missing source directory: $rel_path" >&2
    exit 1
  fi

  if [[ -L "$dst" ]] && [[ "$(readlink -f -- "$dst")" == "$src" ]]; then
    echo "SKIP: $rel_path"
    continue
  fi

  echo "LINK DIR: $rel_path"

  if ((DRY_RUN == 1)); then
    if [[ -e "$dst" || -L "$dst" ]]; then
      echo "  would backup: $dst.bak.$TIMESTAMP"
    fi
    echo "  would symlink: $dst -> $src"
    continue
  fi

  mkdir -p -- "$(dirname -- "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if ! confirm_replace "$dst"; then
      echo "SKIP: $rel_path"
      continue
    fi
    mv -- "$dst" "$dst.bak.$TIMESTAMP"
  fi

  ln -s -- "$src" "$dst"
done

echo "Done."

