DOTFILES_DIR := $(shell pwd)
STOW_PACKAGES := zsh git
SHELL         := /bin/bash

.DEFAULT_GOAL := help

# ---------------------------------------------------------------------------
# Help — lists all targets with their ## comments
# ---------------------------------------------------------------------------
.PHONY: help
help:
	@echo ""
	@echo "  dotfiles"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ---------------------------------------------------------------------------
# Apps
# ---------------------------------------------------------------------------
.PHONY: install-apps
install-apps: ## Install Homebrew if needed, then choose app bundles to install
	@bash $(DOTFILES_DIR)/homebrew/install.sh

# ---------------------------------------------------------------------------
# Dotfiles
# ---------------------------------------------------------------------------
.PHONY: stow
stow:
	@bash $(DOTFILES_DIR)/scripts/stow.sh $(STOW_PACKAGES)

.PHONY: stow-rollback
stow-rollback:
	@bash $(DOTFILES_DIR)/scripts/stow-rollback.sh $(STOW_PACKAGES)

.PHONY: dotfiles-stow
dotfiles-stow: ## Choose dotfile packages to link into $HOME
	@bash $(DOTFILES_DIR)/scripts/dotfiles-stow.sh $(STOW_PACKAGES)

.PHONY: dotfiles-unstow
dotfiles-unstow: ## Choose dotfile packages to unlink from $HOME
	@bash $(DOTFILES_DIR)/scripts/dotfiles-unstow.sh $(STOW_PACKAGES)

.PHONY: git-setup
git-setup: ## Configure Git user.name and user.email
	@bash $(DOTFILES_DIR)/scripts/git-setup.sh

.PHONY: zsh-setup
zsh-setup: ## Configure zsh preferences
	@bash $(DOTFILES_DIR)/scripts/zsh-setup.sh

.PHONY: finder-setup
finder-setup: ## Interactive Finder settings editor
	@bash $(DOTFILES_DIR)/scripts/macos-section.sh finder

.PHONY: dock-setup
dock-setup: ## Interactive Dock settings editor
	@bash $(DOTFILES_DIR)/scripts/macos-section.sh dock

# ---------------------------------------------------------------------------
# Wizard
# ---------------------------------------------------------------------------
.PHONY: the-dots
the-dots: ## Interactive menu to run any target
	@bash $(DOTFILES_DIR)/scripts/the-dots.sh
