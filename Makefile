# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean
INSTALL_FEDORA       ?= scripts/install-fedora
BREW_INSTALLER        = .brew_install.sh

OS := $(shell uname -s)

# ==============================================================================
# MAIN TARGETS
# ==============================================================================
all: install

install: packages configs
	@echo "✅ All setup complete!"

clean:
	@echo "🧹 Cleaning up dotfiles..."
	@bash $(CLEAN_SCRIPT)
	@rm -f $(BREW_INSTALLER)
	@echo "🧼 Clean complete."

# ==============================================================================
# PACKAGES — routed per OS
# ==============================================================================
packages:
ifeq ($(OS),Darwin)
	@$(MAKE) homebrew brew
else ifeq ($(OS),Linux)
	@$(MAKE) fedora
else
	@echo "❌ Unsupported OS: $(OS)"; exit 1
endif

# --- macOS: Homebrew ---
homebrew: $(BREW_INSTALLER)
	@echo "🍺 Checking/installing Homebrew..."
	@command -v brew >/dev/null 2>&1 || /bin/bash $<

$(BREW_INSTALLER):
	@echo "⏳ Downloading Homebrew install script..."
	@curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' > $@

brew: homebrew Brewfile
	@echo "📦 Running brew bundle..."
	@brew bundle install --cleanup --no-upgrade --file ./Brewfile

# --- Linux: Fedora (dnf + flatpak + cargo + npm + curl installers) ---
fedora: Packages.fedora
	@echo "📦 Installing Fedora packages..."
	@bash $(INSTALL_FEDORA)

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
	@git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) diff --quiet 2>/dev/null || git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) stash
	@git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) pull --rebase
	@git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) stash pop 2>/dev/null || true
ifeq ($(OS),Darwin)
	@echo "📦 Updating brew packages..."
	@brew update && brew upgrade
	@brew bundle install --cleanup --no-upgrade --file ./Brewfile
else ifeq ($(OS),Linux)
	@echo "📦 Updating dnf packages..."
	@sudo dnf upgrade -y
	@flatpak update --user -y || true
	@bash $(INSTALL_FEDORA)
endif
	@echo "🔗 Re-linking configs..."
	@bash $(INSTALL_SCRIPT)
	@echo "✅ Update complete!"

# Dump currently installed packages — only meaningful on macOS (Brewfile).
dump:
ifeq ($(OS),Darwin)
	@brew bundle dump --force --file ./Brewfile
	@echo "📋 Brewfile updated with current packages."
else
	@echo "ℹ️  dump is macOS-only (Brewfile). Edit Packages.fedora by hand."
endif

# ==============================================================================
# VALIDATION
# ==============================================================================
lint:
	@echo "🔍 Validating configs..."
	@zsh -n $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/.zprofile config/zsh/config/*.zsh) && echo "  ✓ Zsh configs OK" || exit 1
	@python3 -m json.tool config/karabiner/karabiner.json > /dev/null && echo "  ✓ Karabiner JSON OK" || exit 1
	@bash -n $(INSTALL_SCRIPT) $(CLEAN_SCRIPT) $(INSTALL_FEDORA) && echo "  ✓ Install scripts OK" || exit 1
	@bash -n Packages.fedora && echo "  ✓ Packages.fedora OK" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
.PHONY: all install clean homebrew brew fedora packages configs update dump lint
