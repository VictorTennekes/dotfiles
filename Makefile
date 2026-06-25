# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean
# NixOS flake dir — the host config is auto-selected by hostname (r2d2).
NIXOS_FLAKE          ?= ./nixos

REPO   := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS     := $(shell uname -s)
# Distro id from /etc/os-release; on Linux we only support 'nixos'.
DISTRO := $(shell . /etc/os-release 2>/dev/null && echo $$ID)

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
# PACKAGES — macOS (Homebrew) or NixOS (declarative rebuild)
# ==============================================================================
packages:
ifeq ($(OS),Darwin)
	@$(MAKE) homebrew brew
else ifeq ($(OS),Linux)
	@$(MAKE) nixos
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
	@brew trust areofyl/fetch 2>/dev/null || true
	@NONINTERACTIVE=1 brew bundle install --no-upgrade --file ./packages/Brewfile

# --- Linux: NixOS only (packages are declarative; host picked by hostname) ---
nixos:
	@if [ "$(DISTRO)" != "nixos" ]; then \
		echo "❌ Linux support is NixOS-only (detected '$(DISTRO)')."; exit 1; \
	fi
	@echo "📦 Rebuilding NixOS configuration (sudo)..."
	@sudo nixos-rebuild switch --flake $(NIXOS_FLAKE)

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
	@NONINTERACTIVE=1 brew update && NONINTERACTIVE=1 brew upgrade
	@echo "📦 Upgrading version:latest casks (skipped by plain upgrade)..."
	@NONINTERACTIVE=1 brew upgrade --cask --greedy claude-code@latest
	@NONINTERACTIVE=1 brew bundle install --no-upgrade --file ./packages/Brewfile
else ifeq ($(OS),Linux)
	@if [ "$(DISTRO)" != "nixos" ]; then echo "❌ Linux support is NixOS-only (detected '$(DISTRO)')."; exit 1; fi
	@echo "📦 Updating NixOS flake inputs + rebuilding..."
	@( cd $(NIXOS_FLAKE) && nix flake update )
	@sudo nixos-rebuild switch --flake $(NIXOS_FLAKE)
endif
	@echo "🔗 Re-linking configs..."
	@bash $(INSTALL_SCRIPT)
	@$(MAKE) zcompile
	@echo "✅ Update complete!"

zcompile:
	@echo "⚡ Compiling zsh files..."
	@zsh -c 'for f in config/zsh/config/*.zsh config/zsh/.zshrc home/.zshenv; do [[ -f $$f ]] && zcompile -U $$f; done'
	@echo "  ✓ Zsh files compiled."

# Dump currently installed packages — only meaningful on macOS (Brewfile).
dump:
ifeq ($(OS),Darwin)
	@brew bundle dump --force --file ./packages/Brewfile
	@echo "📋 Brewfile updated with current packages."
else
	@echo "ℹ️  dump is macOS-only (Brewfile). On NixOS edit nixos/packages.nix by hand."
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
.PHONY: all install clean homebrew brew nixos packages configs zcompile update dump lint
