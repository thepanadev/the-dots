#!/usr/bin/env bash
# Configure zsh preferences that are not managed by Stow.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

ui_section "zsh setup"
ui_skip "No zsh setup steps yet. Use make dotfiles-stow to link zsh dotfiles."