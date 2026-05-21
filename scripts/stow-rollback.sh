#!/usr/bin/env bash
# Unlink one or more stowed packages from $HOME.
# Usage: scripts/stow-rollback.sh <pkg> [<pkg>...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

if [[ $# -eq 0 ]]; then
  ui_error "stow-rollback.sh: at least one package name is required"
  exit 2
fi

command -v stow >/dev/null 2>&1 || brew install stow -q

# --- preview: collect links that would be removed ---
ui_section "Links to remove"
declare -a detected_links=()
for pkg in "$@"; do
  while IFS= read -r line; do
    # stow --simulate prints lines like: UNLINK: <path>
    if [[ "$line" == UNLINK:* ]]; then
      link="${HOME}/${line#UNLINK: }"
      detected_links+=("$link")
      ui_item "$link"
    fi
  done < <(stow -v --simulate --delete --dir="$DOTFILES_DIR" --target="$HOME" "$pkg" 2>&1)
done

if [[ ${#detected_links[@]} -eq 0 ]]; then
  ui_skip "No symlinks found for the requested packages — nothing to do."
  exit 0
fi

# --- confirm after seeing the list ---
ui_confirm "Remove ${#detected_links[@]} symlink(s)?" || { ui_skip "Aborted."; exit 1; }

# --- apply ---
for pkg in "$@"; do
  stow --delete --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
  ui_ok "Unlinked package: $pkg"
done
