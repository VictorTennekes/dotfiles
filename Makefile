# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean

REPO   := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS     := $(shell uname -s)
# bash, not sh: the Arch dump target uses process substitution
SHELL  := /bin/bash

# ==============================================================================
# MAIN TARGETS
# ==============================================================================
all: install

# Guided, re-runnable setup (packages, links, keys, remote access).
install:
	@bash scripts/setup

# Same checks as install, but report only.
doctor:
	@bash scripts/setup --check

clean:
	@echo "🧹 Cleaning up dotfiles..."
	@bash $(CLEAN_SCRIPT)
	@echo "🧼 Clean complete."

# ==============================================================================
# PACKAGES — Homebrew (macOS, bootstrapped by setup); Arch uses
# packages/arch.txt + aur.txt via setup
# ==============================================================================
brew: packages/Brewfile
	@echo "📦 Running brew bundle..."
	@brew trust dbt-labs/dbt-cli hashicorp/tap 2>/dev/null || true
	@NONINTERACTIVE=1 brew bundle install --no-upgrade --file ./packages/Brewfile

# Sync installed packages to exactly match Brewfile (installs + removes).
brew-sync: brew
	@echo "🧹 Pruning packages not in Brewfile..."
	@brew bundle cleanup --force --file ./packages/Brewfile

# ==============================================================================
# MAINTENANCE
# ==============================================================================
update:
	@echo "⬇️  Pulling latest dotfiles..."
	@git -C $(REPO) pull --rebase --autostash
	@$(MAKE) update-packages
	@echo "🔗 Re-linking configs..."
	@bash $(INSTALL_SCRIPT)
	@echo "✅ Update complete!"

ifeq ($(OS),Darwin)
update-packages:
	@echo "📦 Updating brew packages..."
	@NONINTERACTIVE=1 brew update && NONINTERACTIVE=1 brew upgrade -y
	@echo "📦 Upgrading version:latest casks (skipped by plain upgrade)..."
	@NONINTERACTIVE=1 brew upgrade -y --cask --greedy claude-code@latest
	@NONINTERACTIVE=1 brew bundle install --no-upgrade --file ./packages/Brewfile
else
update-packages:
	@echo "📦 Updating packages (pacman + AUR)..."
	@paru -Syu
	@grep -hvE '^[[:space:]]*(#|$$)' packages/arch.txt | sudo pacman -S --needed --noconfirm -
	@grep -hvE '^[[:space:]]*(#|$$)' packages/aur.txt | paru -S --needed --noconfirm -
endif

ifeq ($(OS),Darwin)
# Dump currently installed packages to the Brewfile.
dump:
	@brew bundle dump --force --file ./packages/Brewfile
	@echo "📋 Brewfile updated with current packages."
else
# The Arch lists are curated (grouped, commented), so don't overwrite them:
# show explicitly installed packages that aren't listed yet.
dump:
	@echo "📋 Installed but not in packages/arch.txt or aur.txt:"
	@comm -23 <(pacman -Qqe | grep -vE -- '-debug$$|^paru$$' | sort) \
		<(grep -hvE '^[[:space:]]*(#|$$)' packages/arch.txt packages/aur.txt | sort)
endif

# ==============================================================================
# VALIDATION
# ==============================================================================
lint:
	@echo "🔍 Validating configs..."
	@zsh -n $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/.zprofile config/zsh/config/*.zsh) && echo "  ✓ Zsh configs OK" || exit 1
	@python3 -m json.tool config-macos/karabiner/karabiner.json > /dev/null && echo "  ✓ Karabiner JSON OK" || exit 1
	@python3 -m json.tool config-linux/swaync/config.json > /dev/null && echo "  ✓ swaync JSON OK" || exit 1
	@if command -v luac >/dev/null; then luac -p config-linux/hypr/*.lua && echo "  ✓ Hyprland Lua OK" || exit 1; fi
	@bash -n $(INSTALL_SCRIPT) $(CLEAN_SCRIPT) scripts/setup config-linux/hypr/scripts/* config-linux/waybar/scripts/* && echo "  ✓ Scripts OK" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
.PHONY: all install doctor clean brew brew-sync update update-packages dump lint
