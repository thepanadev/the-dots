#!/usr/bin/env bash
# Choose dotfile packages to unlink from $HOME with GNU Stow.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

if [[ $# -eq 0 ]]; then
  ui_error "dotfiles-unstow.sh: at least one package name is required"
  exit 2
fi

command -v stow >/dev/null 2>&1 || brew install stow -q
command -v gum >/dev/null 2>&1 || brew install gum -q

ui_section "Dotfile packages"

selected=""
if ! selected=$(printf '%s\n' "$@" \
  | gum choose --no-limit \
      --header "  Space · toggle   Enter · confirm"); then
  ui_skip "Cancelled."
  exit 0
fi

[[ -z "$selected" ]] && { ui_skip "Nothing selected — aborted."; exit 0; }

selected_packages=()
while IFS= read -r package; do
  [[ -n "$package" ]] && selected_packages+=("$package")
done <<< "$selected"

bash "$SCRIPT_DIR/stow-rollback.sh" "${selected_packages[@]}"