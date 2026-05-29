#!/usr/bin/env bash
# Generate docs/reference/_generated/bash-scripts.md from shell script header comments.
# Edit the SCRIPT_PATTERNS array below to control which scripts are documented.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/reference/_generated"
OUT_FILE="$OUT_DIR/bash-scripts.md"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$OUT_DIR"

# ── Configure: glob patterns relative to repo root ───────────────────────────
SCRIPT_PATTERNS=(
  "scripts/*.sh"
  "wizard.sh"
)
# ─────────────────────────────────────────────────────────────────────────────

# Extract the leading comment block from a script file.
# Skips the shebang line. Strips the "# " prefix. Stops at the first
# blank or non-comment line.
extract_header() {
  awk '
    FNR == 1 && /^#!/ { next }
    /^[[:space:]]*#/ {
      line = $0
      sub(/^[[:space:]]*#[[:space:]]?/, "", line)
      print line
      found = 1
      next
    }
    found { exit }
  ' "$1"
}

{
  cat <<FRONTMATTER
---
title: Bash Scripts
provenance: derived
status: stable
source: scripts/docs/generate-bash-docs.sh
---

!!! warning "Generated page"
    Do not edit by hand.

    Generated at: ${TIMESTAMP}
    Source: \`scripts/docs/generate-bash-docs.sh\`

# Bash Scripts

FRONTMATTER

  for pattern in "${SCRIPT_PATTERNS[@]}"; do
    # Intentional glob expansion — do not quote $REPO_ROOT/$pattern
    for script in $REPO_ROOT/$pattern; do
      [[ -f "$script" ]] || continue
      rel="${script#"$REPO_ROOT"/}"
      echo "## \`$rel\`"
      echo ""
      header="$(extract_header "$script")"
      if [[ -n "$header" ]]; then
        echo "$header"
      else
        echo "No description available. Add a header comment to \`$rel\` to populate this entry."
      fi
      echo ""
    done
  done
} > "$OUT_FILE"

echo "Generated: $OUT_FILE"
