#!/usr/bin/env bash
# Launch the interactive dotfiles wizard, installing gum first if needed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

command -v gum >/dev/null 2>&1 || { ui_subtitle "Installing gum..."; brew install gum; }
bash "$DOTFILES_DIR/wizard.sh"
