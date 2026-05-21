#!/usr/bin/env bash
# Shared UI helpers — source this from any dotfiles script.
# Provides colored, consistently formatted output across all dotfiles scripts.
#
# Usage:
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/ui.sh"   # from macos/
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/ui.sh"      # from root

# ---------------------------------------------------------------------------
# Colors — only emit escape codes when writing to a real terminal
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  _R='\033[0m'           # reset
  _B='\033[1m'           # bold
  _D='\033[2m'           # dim
  _PURPLE='\033[38;5;212m'  # accent (matches wizard.sh gum --foreground 212)
  _GREEN='\033[32m'
  _RED='\033[31m'
  _YELLOW='\033[33m'
  _GRAY='\033[38;5;240m'
else
  _R='' _B='' _D='' _PURPLE='' _GREEN='' _RED='' _YELLOW='' _GRAY=''
fi

# ui_section "Title"      — bold accent header with a blank line above
ui_section()  { printf '\n%b%b  %s%b\n' "$_B" "$_PURPLE" "$1" "$_R"; }

# ui_subtitle "note"      — dim supporting note
ui_subtitle() { printf '%b  %s%b\n' "$_D" "$1" "$_R"; }

# ui_item "description"   — indented gray → item
ui_item()     { printf '%b    → %s%b\n' "$_GRAY" "$1" "$_R"; }

# ui_ok "message"         — ✓ success in green
ui_ok()       { printf '%b  ✓ %s%b\n' "$_GREEN" "$1" "$_R"; }

# ui_applied "message"    — → change applied in green
ui_applied()  { printf '%b  → %s%b\n' "$_GREEN" "$1" "$_R"; }

# ui_skip "message"       — – skipped / neutral in dim
ui_skip()     { printf '%b  – %s%b\n' "$_D" "$1" "$_R"; }

# ui_warn "message"       — ⚠  warning in yellow
ui_warn()     { printf '%b  ⚠  %s%b\n' "$_YELLOW" "$1" "$_R"; }

# ui_error "message"      — ✗ error in red (to stderr)
ui_error()    { printf '%b  ✗ %s%b\n' "$_RED" "$1" "$_R" >&2; }

# ui_confirm "question"   — yes/no prompt; exits 0 on yes, 1 on no
ui_confirm() {
  if command -v gum >/dev/null 2>&1; then
    gum confirm "$1"
  else
    printf '%b  ? %s [y/N] %b' "$_YELLOW" "$1" "$_R"
    read -r _ans
    [[ "$_ans" =~ ^[Yy]$ ]]
  fi
}
