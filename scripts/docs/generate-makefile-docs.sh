#!/usr/bin/env bash
# Generate docs/reference/_generated/make-targets.md from Makefile ## comments.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MAKEFILE="$REPO_ROOT/Makefile"
OUT_DIR="$REPO_ROOT/docs/reference/_generated"
OUT_FILE="$OUT_DIR/make-targets.md"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$OUT_DIR"

{
  cat <<FRONTMATTER
---
title: Make Targets
provenance: derived
status: stable
source: scripts/docs/generate-makefile-docs.sh
---

!!! warning "Generated page"
    Do not edit by hand.

    Generated at: ${TIMESTAMP}
    Source: \`scripts/docs/generate-makefile-docs.sh\`

# Make Targets

| Target | Description |
| --- | --- |
FRONTMATTER

  if [[ ! -f "$MAKEFILE" ]]; then
    echo "_No Makefile found at repo root._"
  else
    awk '/^[a-zA-Z0-9_][a-zA-Z0-9_.-]*[[:space:]]*:.*##/ {
      target = $0
      sub(/:.*/, "", target)
      gsub(/[[:space:]]/, "", target)
      desc = $0
      sub(/.*##[[:space:]]*/, "", desc)
      gsub(/[[:space:]]*$/, "", desc)
      printf "| `%s` | %s |\n", target, desc
    }' "$MAKEFILE"
  fi
} > "$OUT_FILE"

echo "Generated: $OUT_FILE"
