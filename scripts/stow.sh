#!/usr/bin/env bash
# Restow one or more packages from this repo into $HOME.
# Usage: scripts/stow.sh <pkg> [<pkg>...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

if [[ $# -eq 0 ]]; then
  ui_error "stow.sh: at least one package name is required"
  exit 2
fi

command -v stow >/dev/null 2>&1 || brew install stow -q

for pkg in "$@"; do
  if ! stow --restow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"; then
    ui_error "stow: conflict linking '$pkg' — a real file exists in \$HOME. Back it up and remove it, then re-run."
    exit 1
  fi
done
