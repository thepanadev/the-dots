#!/usr/bin/env bash
# Run all documentation generators.
# Output goes to docs/reference/_generated/ (gitignored).
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPTS_DIR/generate-makefile-docs.sh"
bash "$SCRIPTS_DIR/generate-bash-docs.sh"
