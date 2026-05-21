#!/usr/bin/env bash
# Choose dotfile packages to link into $HOME with GNU Stow.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

if [[ $# -eq 0 ]]; then
  ui_error "dotfiles-stow.sh: at least one package name is required"
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

ui_section "Links to create"
detected_links=()
for package in "${selected_packages[@]}"; do
  while IFS= read -r line; do
    if [[ "$line" == LINK:* ]]; then
      link_name="${line#LINK: }"
      link_name="${link_name%% =>*}"
      detected_links+=("$link_name")
      ui_item "~/$link_name"
    fi
  done < <(stow -v --simulate --restow --dir="$DOTFILES_DIR" --target="$HOME" "$package" 2>&1)
done

if [[ ${#detected_links[@]} -eq 0 ]]; then
  ui_skip "Selected packages are already linked — nothing to do."
  exit 0
fi

ui_confirm "Create ${#detected_links[@]} symlink(s)?" || { ui_skip "Aborted."; exit 1; }

bash "$SCRIPT_DIR/stow.sh" "${selected_packages[@]}"
ui_ok "Selected dotfile packages linked."