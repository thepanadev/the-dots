#!/usr/bin/env bash
# Interactive macOS settings editor for a single section.
# Reads desired values from config.sh, lets you edit Finder or Dock settings via gum,
# writes changes back to config.sh, then applies that section directly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"
SECTION="${1:-all}"

case "$SECTION" in
  finder)
    SECTION_PREFIX="FINDER_"
    SECTION_LABEL="Finder"
    APPLY_SCRIPT="$SCRIPT_DIR/finder.sh"
    ;;
  dock)
    SECTION_PREFIX="DOCK_"
    SECTION_LABEL="Dock"
    APPLY_SCRIPT="$SCRIPT_DIR/dock.sh"
    ;;
  all)
    SECTION_PREFIX=""
    SECTION_LABEL="macOS"
    APPLY_SCRIPT="$SCRIPT_DIR/defaults.sh"
    ;;
  *)
    printf 'Unknown macOS section: %s\n' "$SECTION" >&2
    exit 1
    ;;
esac

# shellcheck source=../lib/ui.sh
source "$SCRIPT_DIR/../lib/ui.sh"

if ! command -v gum &>/dev/null; then
  ui_error "gum is required. Run: brew install gum"
  exit 1
fi

# ---------------------------------------------------------------------------
# Parse config.sh structure once — fills parallel arrays:
#   VARNAMES, TYPES, CONSTRAINTS, LABELS
# Line format: VARNAME=value  # [type:constraints]  Description
# ---------------------------------------------------------------------------
VARNAMES=()
TYPES=()
CONSTRAINTS=()
LABELS=()

while IFS= read -r line; do
  [[ "$line" =~ ^([A-Z_]+)= ]] || continue
  varname="${BASH_REMATCH[1]}"
  [[ -z "$SECTION_PREFIX" || "$varname" == "$SECTION_PREFIX"* ]] || continue
  [[ "$line" =~ \[([a-z]+)(:([^]]+))?\][[:space:]]+(.*) ]] || continue
  VARNAMES+=("$varname")
  TYPES+=("${BASH_REMATCH[1]}")
  CONSTRAINTS+=("${BASH_REMATCH[3]:-}")
  LABELS+=("${BASH_REMATCH[4]}")
done < "$CONFIG_FILE"

if [[ ${#VARNAMES[@]} -eq 0 ]]; then
  ui_error "No settings found for $SECTION_LABEL."
  exit 1
fi

# ---------------------------------------------------------------------------
# Update a variable's value in config.sh (preserves the inline comment).
# For string type, wraps value in quotes; otherwise writes bare.
# ---------------------------------------------------------------------------
set_config_value() {
  local varname="$1" new_val="$2" type="$3"
  if [[ "$type" == "string" ]]; then
    sed -i '' "s|^$varname=.*#|$varname=\"$new_val\"  #|" "$CONFIG_FILE"
  else
    sed -i '' "s|^$varname=.*#|$varname=$new_val  #|" "$CONFIG_FILE"
  fi
}

# ---------------------------------------------------------------------------
# Select settings to edit, preview the resulting config changes, then apply.
# ---------------------------------------------------------------------------
# shellcheck source=macos/config.sh
source "$CONFIG_FILE"

DISPLAY=()
CURRENT_VALUES=()
NEW_VALUES=()
for i in "${!VARNAMES[@]}"; do
  varname="${VARNAMES[$i]}"
  type="${TYPES[$i]}"
  label="${LABELS[$i]}"
  cur_val="${!varname}"
  CURRENT_VALUES+=("$cur_val")
  NEW_VALUES+=("$cur_val")
  DISPLAY+=("$label (current: $cur_val)")
done

ui_section "Select $SECTION_LABEL settings to update"
ui_subtitle "Choose the settings to edit; changes will be previewed before applying."

SELECTED=$(printf '%s\n' "${DISPLAY[@]}" \
  | gum choose --no-limit \
      --header "  Space · toggle   Enter · confirm" \
      --cursor "❯ " \
      --height 20) || { ui_skip "Cancelled."; exit 0; }
[[ -z "$SELECTED" ]] && { ui_skip "Nothing selected — aborted."; exit 0; }

SELECTED_INDICES=()
while IFS= read -r selected_item; do
  for i in "${!DISPLAY[@]}"; do
    if [[ "${DISPLAY[$i]}" == "$selected_item" ]]; then
      SELECTED_INDICES+=("$i")
      break
    fi
  done
done <<< "$SELECTED"

for target_idx in "${SELECTED_INDICES[@]}"; do
  type="${TYPES[$target_idx]}"
  constraints="${CONSTRAINTS[$target_idx]}"
  label="${LABELS[$target_idx]}"
  cur_val="${CURRENT_VALUES[$target_idx]}"

  case "$type" in
    bool)
      if [[ "$cur_val" == "true" ]]; then OPTS=("true" "false")
      else                                OPTS=("false" "true"); fi
      NEW_VAL=$(printf '%s\n' "${OPTS[@]}" | gum choose \
        --header "  $label  ·  Enter · confirm" \
        --cursor "❯ " \
        --height 4) || { ui_skip "Cancelled."; exit 0; }
      NEW_VALUES[$target_idx]="$NEW_VAL"
      ;;
    int)
      while true; do
        NEW_VAL=$(gum input \
          --value "$cur_val" \
          --placeholder "$constraints" \
          --header "  $label  (range: $constraints)" \
          --prompt "> ") || { ui_skip "Cancelled."; exit 0; }
        if [[ -n "$constraints" && "$constraints" == *-* ]]; then
          min="${constraints%%-*}"
          max="${constraints##*-}"
          if ! [[ "$NEW_VAL" =~ ^[0-9]+$ ]] || (( NEW_VAL < min || NEW_VAL > max )); then
            ui_warn "Invalid: must be an integer between $min and $max."
            continue
          fi
        fi
        NEW_VALUES[$target_idx]="$NEW_VAL"
        break
      done
      ;;
    string)
      if [[ -n "$constraints" ]]; then
        IFS='|' read -ra OPTIONS <<< "$constraints"
        SORTED=("$cur_val")
        for opt in "${OPTIONS[@]}"; do
          [[ "$opt" != "$cur_val" ]] && SORTED+=("$opt")
        done
        NEW_VAL=$(printf '%s\n' "${SORTED[@]}" | gum choose \
          --header "  $label  ·  Enter · confirm" \
          --cursor "❯ " \
          --height 8) || { ui_skip "Cancelled."; exit 0; }
      else
        # Reject chars that could inject code when config.sh is sourced, or break the sed write.
        forbidden='[`$\|&#"]'
        while true; do
          NEW_VAL=$(gum input \
            --value "$cur_val" \
            --header "  $label" \
            --prompt "> ") || { ui_skip "Cancelled."; exit 0; }
          if [[ "$NEW_VAL" =~ $forbidden ]]; then
            ui_warn "Invalid: cannot contain \` \$ \\ \" | & #"
            continue
          fi
          break
        done
      fi
      NEW_VALUES[$target_idx]="$NEW_VAL"
      ;;
  esac
done

ui_section "$SECTION_LABEL settings to apply"
for target_idx in "${SELECTED_INDICES[@]}"; do
  old_val="${CURRENT_VALUES[$target_idx]}"
  new_val="${NEW_VALUES[$target_idx]}"
  label="${LABELS[$target_idx]}"
  if [[ "$old_val" == "$new_val" ]]; then
    ui_item "$label: $new_val (unchanged in config)"
  else
    ui_item "$label: $old_val → $new_val"
  fi
done

ui_confirm "Save selected changes and apply $SECTION_LABEL settings?" || { ui_skip "Aborted."; exit 0; }

for target_idx in "${SELECTED_INDICES[@]}"; do
  old_val="${CURRENT_VALUES[$target_idx]}"
  new_val="${NEW_VALUES[$target_idx]}"
  [[ "$old_val" == "$new_val" ]] && continue
  set_config_value "${VARNAMES[$target_idx]}" "$new_val" "${TYPES[$target_idx]}"
done

bash "$APPLY_SCRIPT"
