# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean

REPO   := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS     := $(shell uname -s)
# bash, not sh: the Fedora dump target uses process substitution
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
	@bash $(CLEAN_SCRIPT)

# ==============================================================================
# PACKAGES — Homebrew (macOS, bootstrapped by setup); Fedora uses
# packages/fedora.txt (dnf + Terra) via setup
# ==============================================================================
brew: packages/Brewfile
	@echo "📦 Running brew bundle..."
	@brew trust dbt-labs/dbt-cli hashicorp/tap || true
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
	@echo "📦 Updating packages (dnf + Terra)..."
	@sudo dnf upgrade -y --refresh
	@sed 's/#.*//' packages/fedora.txt | awk 'NF { print $$1 }' | \
		xargs sudo dnf install -y --setopt=install_weak_deps=False
	@sed 's/#.*//' packages/fedora.txt | awk 'NF { print $$1 }' | \
		xargs sudo dnf mark user -y >/dev/null
endif

ifeq ($(OS),Darwin)
# Dump currently installed packages to the Brewfile.
dump:
	@brew bundle dump --force --file ./packages/Brewfile
	@echo "📋 Brewfile updated with current packages."
else
# The Fedora list is curated (grouped, commented), so don't overwrite it:
# show packages installed by hand (install reason "User", not a dependency or
# the installer's package group) that aren't listed.
dump:
	@echo "📋 Installed by hand but not in packages/fedora.txt:"
	@comm -23 <(dnf repoquery --installed --qf '%{name} %{reason}\n' 2>/dev/null | \
		awk '$$2 == "User" { print $$1 }' | sort -u) \
		<(sed 's/#.*//' packages/fedora.txt | awk 'NF { print $$1 }' | sort)
endif

# ==============================================================================
# VALIDATION
# ==============================================================================
lint:
	@echo "🔍 Validating configs..."
	@for f in $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/.zprofile config/zsh/config/*.zsh); do \
		zsh -n "$$f" || exit 1; done && echo "  ✓ Zsh configs OK"
	@python3 -m json.tool config-linux/swaync/config.json > /dev/null && echo "  ✓ swaync JSON OK" || exit 1
	@if command -v niri >/dev/null; then \
		out=$$(niri validate -c config-linux/niri/config.kdl 2>&1) || { echo "$$out"; exit 1; }; \
		echo "  ✓ niri config OK"; fi
	@shellcheck -S warning $(INSTALL_SCRIPT) $(CLEAN_SCRIPT) scripts/setup scripts/tpm-enroll scripts/macos-defaults config-linux/niri/scripts/* config-linux/waybar/scripts/* config-macos/swiftbar/*.sh && echo "  ✓ Scripts OK (shellcheck)" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
.PHONY: all install doctor clean brew brew-sync update update-packages dump lint
