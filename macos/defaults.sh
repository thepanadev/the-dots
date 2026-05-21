#!/usr/bin/env bash
# Runner — applies macOS desired-state tweaks from config.sh.
# Pass MACOS_MODE=status to inspect without applying.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=../lib/ui.sh
source "$SCRIPT_DIR/../lib/ui.sh"

export MACOS_MODE="${MACOS_MODE:-apply}"

bash "$SCRIPT_DIR/finder.sh"
bash "$SCRIPT_DIR/dock.sh"

if [[ "$MACOS_MODE" == "apply" ]]; then
  ui_ok "All macOS tweaks applied."
else
  ui_ok "Status check complete."
fi
