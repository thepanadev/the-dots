#!/usr/bin/env bash
# Desired-state helpers — source this file; do NOT execute directly.
# Requires: ui.sh already sourced, MACOS_MODE env var (apply|status).
# Sets CHANGED=true in the sourcing script's scope when a value is applied.

# apply_bool "Label" domain key desired
apply_bool() {
  local label="$1" domain="$2" key="$3" desired="$4"
  local current current_label
  if current=$(defaults read "$domain" "$key" 2>/dev/null); then
    [[ "$current" == "1" ]] && current_label="true" || current_label="false"
  else
    current_label="(unset)"
  fi

  if [[ "${MACOS_MODE:-apply}" == "status" ]]; then
    if [[ "$current_label" == "$desired" ]]; then
      ui_skip "$label: $desired"
    else
      ui_warn "$label: $current_label  →  $desired"
    fi
    return
  fi

  if [[ "$current_label" == "$desired" ]]; then
    ui_skip "$label: already $desired"
  else
    defaults write "$domain" "$key" -bool "$desired"
    ui_applied "$label: $current_label → $desired"
    CHANGED=true
  fi
}

# apply_int "Label" domain key desired
apply_int() {
  local label="$1" domain="$2" key="$3" desired="$4"
  local current
  current=$(defaults read "$domain" "$key" 2>/dev/null) || current="(unset)"

  if [[ "${MACOS_MODE:-apply}" == "status" ]]; then
    if [[ "$current" == "$desired" ]]; then
      ui_skip "$label: $desired"
    else
      ui_warn "$label: $current  →  $desired"
    fi
    return
  fi

  if [[ "$current" == "$desired" ]]; then
    ui_skip "$label: already $desired"
  else
    defaults write "$domain" "$key" -int "$desired"
    ui_applied "$label: $current → $desired"
    CHANGED=true
  fi
}

# apply_string "Label" domain key desired
apply_string() {
  local label="$1" domain="$2" key="$3" desired="$4"
  local current
  current=$(defaults read "$domain" "$key" 2>/dev/null) || current="(unset)"

  if [[ "${MACOS_MODE:-apply}" == "status" ]]; then
    if [[ "$current" == "$desired" ]]; then
      ui_skip "$label: $desired"
    else
      ui_warn "$label: $current  →  $desired"
    fi
    return
  fi

  if [[ "$current" == "$desired" ]]; then
    ui_skip "$label: already $desired"
  else
    defaults write "$domain" "$key" -string "$desired"
    ui_applied "$label: $current → $desired"
    CHANGED=true
  fi
}

# apply_library_visibility "Label" desired
# desired="true"  → ~/Library should be visible (chflags nohidden)
# desired="false" → ~/Library should be hidden  (chflags hidden)
apply_library_visibility() {
  local label="$1" desired="$2"
  local currently_hidden=false
  ls -ldO ~/Library 2>/dev/null | grep -q hidden && currently_hidden=true

  local current_display desired_display
  [[ "$currently_hidden" == "true" ]] && current_display="hidden" || current_display="visible"
  [[ "$desired" == "true" ]]          && desired_display="visible" || desired_display="hidden"

  if [[ "${MACOS_MODE:-apply}" == "status" ]]; then
    if [[ "$current_display" == "$desired_display" ]]; then
      ui_skip "$label: $desired_display"
    else
      ui_warn "$label: $current_display  →  $desired_display"
    fi
    return
  fi

  if [[ "$current_display" == "$desired_display" ]]; then
    ui_skip "$label: already $desired_display"
  else
    if [[ "$desired" == "true" ]]; then
      chflags nohidden ~/Library
    else
      chflags hidden ~/Library
    fi
    ui_applied "$label: $current_display → $desired_display"
    CHANGED=true
  fi
}
