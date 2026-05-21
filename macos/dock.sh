#!/usr/bin/env bash
# Dock desired-state tweaks — compares config.sh values against current state
# and applies only what differs. Idempotent.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/ui.sh
source "$SCRIPT_DIR/../lib/ui.sh"
# shellcheck source=config.sh
source "$SCRIPT_DIR/config.sh"
# shellcheck source=helpers.sh
source "$SCRIPT_DIR/helpers.sh"

CHANGED=false

ui_section "Dock"

apply_int  "Icon size"              "com.apple.dock" "tilesize"      "$DOCK_TILE_SIZE"
apply_bool "Magnification on hover" "com.apple.dock" "magnification" "$DOCK_MAGNIFICATION"
apply_int  "Magnification max size" "com.apple.dock" "largesize"     "$DOCK_LARGE_SIZE"

if [[ "$CHANGED" == "true" && "${MACOS_MODE:-apply}" == "apply" ]]; then
  killall Dock 2>/dev/null || true
fi

ui_ok "Dock done."
