#!/usr/bin/env bash
# Finder desired-state tweaks — compares config.sh values against current state
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

ui_section "Finder"

apply_bool   "Show hidden files"        "com.apple.finder" "AppleShowAllFiles"              "$FINDER_SHOW_HIDDEN"
apply_bool   "Show all extensions"      "NSGlobalDomain"   "AppleShowAllExtensions"         "$FINDER_SHOW_EXTENSIONS"
apply_bool   "POSIX path in title bar"  "com.apple.finder" "_FXShowPosixPathInTitle"        "$FINDER_POSIX_PATH_TITLE"
apply_bool   "Status bar"               "com.apple.finder" "ShowStatusBar"                  "$FINDER_SHOW_STATUS_BAR"
apply_bool   "Path bar"                 "com.apple.finder" "ShowPathbar"                    "$FINDER_SHOW_PATH_BAR"
apply_string "Default search scope"     "com.apple.finder" "FXDefaultSearchScope"           "$FINDER_SEARCH_SCOPE"
apply_bool   "Extension change warning" "com.apple.finder" "FXEnableExtensionChangeWarning" "$FINDER_EXTENSION_WARNING"
apply_library_visibility "~/Library visibility" "$FINDER_LIBRARY_VISIBLE"

if [[ "$CHANGED" == "true" && "${MACOS_MODE:-apply}" == "apply" ]]; then
  killall Finder 2>/dev/null || true
fi

ui_ok "Finder done."
