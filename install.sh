#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [--dry-run]

Copies tracked files under .config/ to ~/.config/.
Existing different files are backed up with .bak.YYYYmmdd-HHMMSS.
This script does not require sudo.
EOF
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

mapfile -t files < <(git -C "$REPO_ROOT" ls-files '.config/**')

if ((${#files[@]} == 0)); then
  echo "ERROR: No tracked .config files found." >&2
  exit 1
fi

for rel_path in "${files[@]}"; do
  src="$REPO_ROOT/$rel_path"
  dst="$HOME/$rel_path"

  if [[ ! -f "$src" ]]; then
    echo "WARN: Missing source: $rel_path" >&2
    continue
  fi

  if [[ -f "$dst" ]] && cmp -s -- "$src" "$dst"; then
    echo "SKIP: $rel_path"
    continue
  fi

  echo "INSTALL: $rel_path"

  if ((DRY_RUN == 1)); then
    if [[ -e "$dst" ]]; then
      echo "  would backup: $dst.bak.$TIMESTAMP"
    fi
    continue
  fi

  mkdir -p -- "$(dirname -- "$dst")"

  if [[ -e "$dst" ]]; then
    cp -a -- "$dst" "$dst.bak.$TIMESTAMP"
  fi

  cp -a -- "$src" "$dst"
done

echo "Done."

