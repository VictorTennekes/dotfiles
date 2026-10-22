# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean

REPO   := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS     := $(shell uname -s)

# ==============================================================================
# MAIN TARGETS
# ==============================================================================
all: install

install: packages configs zcompile
	@echo "✅ All setup complete!"

clean:
	@echo "🧹 Cleaning up dotfiles..."
	@bash $(CLEAN_SCRIPT)
	@echo "🧼 Clean complete."

# ==============================================================================
# PACKAGES — macOS (Homebrew); Linux (CachyOS) packages are installed by hand
# ==============================================================================
packages:
ifeq ($(OS),Darwin)
	@$(MAKE) homebrew brew
else ifeq ($(OS),Linux)
	@echo "ℹ️  Linux: no package manifest — install packages with pacman/paru by hand."
else
	@echo "❌ Unsupported OS: $(OS)"; exit 1
endif

# --- macOS: Homebrew ---
homebrew:
	@echo "🍺 Checking/installing Homebrew..."
	@command -v brew >/dev/null 2>&1 || \
		curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' | /bin/bash

brew: homebrew packages/Brewfile
	@echo "📦 Running brew bundle..."
	@brew trust dbt-labs/dbt-cli hashicorp/tap lightdash/lightdash 2>/dev/null || true
	@NONINTERACTIVE=1 brew bundle install --no-upgrade --file ./packages/Brewfile

# Sync installed packages to exactly match Brewfile (installs + removes).
brew-sync: brew
	@echo "🧹 Pruning packages not in Brewfile..."
	@brew bundle cleanup --force --file ./packages/Brewfile

# ==============================================================================
# CONFIGURATION SYMLINKS
# ==============================================================================
configs:
	@echo "🔗 Symlinking configuration files..."
	@bash $(INSTALL_SCRIPT)

# ==============================================================================
# MAINTENANCE
# ==============================================================================
update:
	@echo "⬇️  Pulling latest dotfiles..."
	@git -C $(REPO) diff --quiet 2>/dev/null || git -C $(REPO) stash
	@git -C $(REPO) pull --rebase
	@git -C $(REPO) stash list | grep -q stash && \
		{ git -C $(REPO) stash pop || { echo "❌ Stash pop had conflicts — resolve manually, then re-run"; exit 1; }; } || true
ifeq ($(OS),Darwin)
	@echo "📦 Updating brew packages..."
	@NONINTERACTIVE=1 brew update && NONINTERACTIVE=1 brew upgrade -y
	@echo "📦 Upgrading version:latest casks (skipped by plain upgrade)..."
	@NONINTERACTIVE=1 brew upgrade -y --cask --greedy claude-code@latest
	@NONINTERACTIVE=1 brew bundle install --no-upgrade --file ./packages/Brewfile
else ifeq ($(OS),Linux)
	@echo "📦 Updating system packages..."
	@if command -v paru >/dev/null 2>&1; then paru -Syu; else sudo pacman -Syu; fi
endif
	@echo "🔗 Re-linking configs..."
	@bash $(INSTALL_SCRIPT)
	@$(MAKE) zcompile
	@echo "✅ Update complete!"

zcompile:
	@echo "⚡ Compiling zsh files..."
	@zsh -c 'for f in config/zsh/config/*.zsh config/zsh/.zshrc home/.zshenv; do [[ -f $$f ]] && zcompile -U $$f; done'
	@echo "  ✓ Zsh files compiled."

# Dump currently installed packages — macOS only (Brewfile).
dump:
ifeq ($(OS),Darwin)
	@brew bundle dump --force --file ./packages/Brewfile
	@echo "📋 Brewfile updated with current packages."
else
	@echo "ℹ️  dump is macOS-only (Brewfile)."
endif

# ==============================================================================
# VALIDATION
# ==============================================================================
lint:
	@echo "🔍 Validating configs..."
	@zsh -n $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/.zprofile config/zsh/config/*.zsh) && echo "  ✓ Zsh configs OK" || exit 1
	@if [ "$(OS)" = "Darwin" ]; then command -v python3 >/dev/null 2>&1 && python3 -m json.tool darwin/karabiner/karabiner.json > /dev/null && echo "  ✓ Karabiner JSON OK" || echo "  ⚠ Skipping Karabiner JSON check (python3 missing)"; fi
	@bash -n $(INSTALL_SCRIPT) $(CLEAN_SCRIPT) && echo "  ✓ Install scripts OK" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
.PHONY: all install clean homebrew brew brew-sync packages configs zcompile update dump lint
