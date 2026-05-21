#!/usr/bin/env bash
# Interactive TUI for the dotfiles Makefile.
# Parses targets, descriptions, and recipes directly from Makefile — always in sync.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAKEFILE="$DOTFILES_DIR/Makefile"

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
if ! command -v gum &>/dev/null; then
  printf '\033[31m  gum not found.\033[0m  Install with: brew install gum\n' >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Makefile parsers
# ---------------------------------------------------------------------------

# All documented targets as "TARGET  description" (reads ## comments)
menu_items() {
  grep -E '^[a-zA-Z_-]+:.*## ' "$MAKEFILE" \
    | grep -v '^the-dots:' \
    | sed 's/:.*## /\t/' \
    | awk -F'\t' '{printf "%-18s  %s\n", $1, $2}'
}

# Description string for one target
desc_for() {
  grep -E "^$1:.*## " "$MAKEFILE" | sed 's/.*## //'
}

# Prerequisite targets listed after the colon (e.g. "macos: snapshot" → "snapshot")
deps_for() {
  local dep

  while IFS= read -r dep; do
    grep -Eq "^$dep:.*## " "$MAKEFILE" && printf '%s\n' "$dep"
  done < <(
    grep -E "^$1:" "$MAKEFILE" \
      | sed "s/^$1://" \
      | sed 's/#.*//' \
      | tr ' ' '\n' \
      | grep -v '^\s*$' || true
  )

  return 0
}

# Recipe lines for a target, cleaned up for human reading
recipe_for() {
  awk -v t="$1" '
    /^\.PHONY/ { next }
    $0 ~ "^"t"[: \t]" { found=1; next }
    found && /^\t/ {
      line = substr($0, 2)
      sub(/^@/,              "",    line)   # strip make silence prefix
      gsub(/\$\(DOTFILES_DIR\)/, ".", line) # shorten absolute path
      gsub(/\$\(HOME\)/,    "~",    line)
      gsub(/\$\(STOW_PACKAGES\)/, "zsh git", line)
      gsub(/\$\(MAKE\)/,    "make", line)
      print line
    }
    found && !/^\t/ && !/^$/ { exit }
  ' "$MAKEFILE"
}

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------
clear

gum style \
  --foreground 212 --border-foreground 212 --border double \
  --align center --width 54 --padding "0 2" --margin "1 2" \
  " The Pana Dev dotfiles "

# Pick a target
SELECTED=$(menu_items | gum choose \
  --header "  Select a target to run:" \
  --cursor "❯ " \
  --height 12)

TARGET=$(awk '{print $1}' <<< "$SELECTED")
DESC=$(desc_for "$TARGET")
DEPS=$(deps_for "$TARGET")
RECIPE=$(recipe_for "$TARGET")

# Build detail panel
DETAIL="$(gum style --bold --foreground 212 "make $TARGET")
$(gum style --faint "$DESC")"

if [ -n "$DEPS" ]; then
  DEP_LINES=$(awk '{print "  → " $0}' <<< "$DEPS")
  DETAIL="$DETAIL

$(gum style --foreground 240 "also runs first:")
$DEP_LINES"
fi

if [ -n "$RECIPE" ]; then
  RECIPE_LINES=$(awk '{print "  " $0}' <<< "$RECIPE")
  DETAIL="$DETAIL

$(gum style --foreground 240 "commands:")
$RECIPE_LINES"
fi

echo ""
gum style --border rounded --padding "1 2" --margin "0 2" --border-foreground 240 "$DETAIL"
echo ""

# Confirm and run
# For targets that self-confirm after previewing their effects,
# skip the wizard confirm so the user sees what will happen first.
SELF_CONFIRM_TARGETS="install-apps dotfiles-stow dotfiles-unstow finder-setup dock-setup"
if [[ " $SELF_CONFIRM_TARGETS " == *" $TARGET "* ]]; then
  echo ""
  make -C "$DOTFILES_DIR" "$TARGET"
elif gum confirm "  Run make $TARGET?" --default=false; then
  echo ""
  gum style --faint "  running make $TARGET..."
  echo ""
  make -C "$DOTFILES_DIR" "$TARGET"
else
  echo ""
  gum style --faint "  Cancelled."
fi
