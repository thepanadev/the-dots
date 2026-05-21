#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLES_DIR="$SCRIPT_DIR/bundles"

# shellcheck source=../lib/ui.sh
source "$SCRIPT_DIR/../lib/ui.sh"

# -- Bundle metadata --------------------------------------------------------
BUNDLES=(craft terminal ai productivity)

bundle_label() {
    case "$1" in
        craft)        echo "Craft — editors, version control, dev tools & containers" ;;
        terminal)     echo "Terminal — shells, CLI utilities & data tools" ;;
        ai)           echo "AI & coding assistants" ;;
        productivity) echo "Productivity — browsers, desktop, notes & security" ;;
    esac
}

# -- Helper: list contents of a Brewfile ------------------------------------
show_bundle_contents() {
    local file="$1"
    while IFS= read -r line; do
        [[ "$line" =~ ^(brew|cask)[[:space:]]+\"([^\"]+)\" ]] || continue
        local name="${BASH_REMATCH[2]}"
        local desc=""
        [[ "$line" =~ \#[[:space:]]*(.+)$ ]] && desc="${BASH_REMATCH[1]}"
        if [ -n "$desc" ]; then
            ui_item "$name  — $desc"
        else
            ui_item "$name"
        fi
    done < "$file"
}

# -- Ensure Homebrew is installed ------------------------------------------
brew_bin="$(command -v brew || true)"
if [ -z "$brew_bin" ]; then
    ui_warn "Homebrew not found — installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if   [ -x /opt/homebrew/bin/brew ]; then brew_bin=/opt/homebrew/bin/brew
    elif [ -x /usr/local/bin/brew    ]; then brew_bin=/usr/local/bin/brew
    else ui_error "brew not found after install."; exit 1
    fi
else
    ui_ok "Homebrew already installed"
fi

# -- Ensure gum is installed -----------------------------------------------
command -v gum >/dev/null 2>&1 || "$brew_bin" install gum

# -- Pick bundles -----------------------------------------------------------
ui_section "Select bundles to install"

CHOICES=()
for name in "${BUNDLES[@]}"; do
    CHOICES+=("$(bundle_label "$name")")
done

SELECTED=""
if ! SELECTED=$(printf '%s\n' "${CHOICES[@]}" \
    | gum choose --no-limit \
        --header "  Space · toggle   Enter · confirm"); then
    ui_skip "Cancelled."; exit 0
fi
[[ -z "$SELECTED" ]] && { ui_skip "Nothing selected — aborted."; exit 0; }

# Map selected labels back to bundle names
SELECTED_BUNDLES=()
for name in "${BUNDLES[@]}"; do
    label="$(bundle_label "$name")"
    if printf '%s\n' "$SELECTED" | grep -qF "$label"; then
        SELECTED_BUNDLES+=("$name")
    fi
done

# -- Show what will be installed -------------------------------------------
ui_section "Apps to install"
for name in "${SELECTED_BUNDLES[@]}"; do
    ui_subtitle "$(bundle_label "$name")"
    show_bundle_contents "$BUNDLES_DIR/$name.Brewfile"
done

# -- Confirm ---------------------------------------------------------------
ui_confirm "Install selected bundles?" || { ui_skip "Aborted."; exit 0; }

# -- Install bundles -------------------------------------------------------
ui_section "Installing"
for name in "${SELECTED_BUNDLES[@]}"; do
    ui_subtitle "$(bundle_label "$name")"
    "$brew_bin" bundle --file="$BUNDLES_DIR/$name.Brewfile"
done

ui_ok "All selected bundles installed"
