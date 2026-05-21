#!/usr/bin/env bash
# Run a macOS settings section interactively via the gum-based menu.
#
# Usage: scripts/macos-section.sh <section>
#   <section> is "finder" or "dock" (anything matching macos/<section>.sh).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

section="${1:-}"
if [[ -z "$section" ]]; then
  ui_error "macos-section.sh: section name is required (e.g. finder, dock)"
  exit 2
fi

command -v gum >/dev/null 2>&1 || { ui_subtitle "Installing gum..."; brew install gum; }
bash "$DOTFILES_DIR/macos/menu.sh" "$section"
