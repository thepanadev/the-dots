#!/usr/bin/env bash
# Configure local Git identity for this machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_FILE="$HOME/.gitconfig.local"
ENSURE_ONLY=false

prompt_input() {
	local var_name="$1"
	local prompt_text="$2"
	local prompt_value

	read -r -p "$prompt_text" prompt_value < /dev/tty
	printf -v "$var_name" '%s' "$prompt_value"
}

if [[ "${1:-}" == "--ensure" ]]; then
	ENSURE_ONLY=true
fi

# shellcheck source=../lib/ui.sh
source "$DOTFILES_DIR/lib/ui.sh"

if [[ -f "$TARGET_FILE" ]]; then
	if [[ "$ENSURE_ONLY" == "true" ]]; then
		ui_skip "~/.gitconfig.local already exists."
		exit 0
	fi

	ui_warn "~/.gitconfig.local already exists."
	prompt_input overwrite "  Overwrite it? [y/N] "
	if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
		ui_skip "Skipped."
		exit 0
	fi
fi

prompt_input git_name "  Git user.name: "
if [[ -z "$git_name" ]]; then
	ui_error "user.name is required."
	exit 1
fi

prompt_input git_email "  Git user.email: "
if [[ -z "$git_email" ]]; then
	ui_error "user.email is required."
	exit 1
fi

printf '[user]\n\tname = %s\n\temail = %s\n' "$git_name" "$git_email" > "$TARGET_FILE"
ui_ok "~/.gitconfig.local written."