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

Symlinks config files under .config/ into ~/.config/.
Existing files are replaced only after confirmation, and are backed up
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

mapfile -t files < <(git -C "$REPO_ROOT" ls-files --cached --others --exclude-standard '.config/**')

if ((${#files[@]} == 0)); then
  echo "ERROR: No .config files found." >&2
  exit 1
fi

for rel_path in "${files[@]}"; do
  src="$REPO_ROOT/$rel_path"
  dst="$HOME/$rel_path"

  if [[ ! -f "$src" ]]; then
    echo "WARN: Missing source: $rel_path" >&2
    continue
  fi

  if [[ -L "$dst" ]] && [[ "$(readlink -f -- "$dst")" == "$src" ]]; then
    echo "SKIP: $rel_path"
    continue
  fi

  echo "LINK: $rel_path"

  if ((DRY_RUN == 1)); then
    if [[ -e "$dst" ]]; then
      echo "  would backup: $dst.bak.$TIMESTAMP"
    fi
    echo "  would symlink: $dst -> $src"
    continue
  fi

  mkdir -p -- "$(dirname -- "$dst")"

  if [[ -e "$dst" ]]; then
    if ! confirm_replace "$dst"; then
      echo "SKIP: $rel_path"
      continue
    fi
    mv -- "$dst" "$dst.bak.$TIMESTAMP"
  fi

  ln -s -- "$src" "$dst"
done

echo "Done."

