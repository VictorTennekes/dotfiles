# ==============================================================================
# VARIABLES
# ==============================================================================
# Assume scripts are in a 'scripts' subdirectory
INSTALL_SCRIPT ?= scripts/install
CLEAN_SCRIPT ?= scripts/clean

# Homebrew install script will be downloaded here
BREW_INSTALLER = .brew_install.sh

# ==============================================================================
# MAIN TARGETS
# ==============================================================================
# Default target when running `make`
all: install

# Main installation orchestrator: first packages, then configs.
install: homebrew brew configs
	@echo "✅ All setup complete!"

# The clean target now calls the clean script and removes downloaded files.
clean:
	@echo "🧹 Cleaning up dotfiles..."
	@bash $(CLEAN_SCRIPT)
	@rm -f $(BREW_INSTALLER)
	@echo "🧼 Clean complete."

# ==============================================================================
# HOMEBREW: SYSTEM & APPLICATION INSTALLATION
# ==============================================================================
# Ensures Homebrew itself is installed.
homebrew: $(BREW_INSTALLER)
	@echo "🍺 Checking/installing Homebrew..."
	@command -v brew >/dev/null 2>&1 || /bin/bash $<

# Downloads the Homebrew installer script if it doesn't exist.
$(BREW_INSTALLER):
	@echo "⏳ Downloading Homebrew install script..."
	@curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' > $@

# Runs `brew bundle` to install all packages from the Brewfile.
brew: homebrew Brewfile
	@echo "📦 Running brew bundle..."
	@brew bundle install --cleanup --no-upgrade --file ./Brewfile

# ==============================================================================
# CONFIGURATION & THEMES
# ==============================================================================
# This single target handles all configuration symlinking by calling your script.
# It also includes the logic for downloading themes.
configs:
	@echo "🔗 Symlinking configuration files..."
	@bash $(INSTALL_SCRIPT)

# ==============================================================================
# MAINTENANCE
# ==============================================================================
# Pull latest dotfiles, update brew packages, and re-link configs.
update:
	@echo "⬇️  Pulling latest dotfiles..."
	@git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) diff --quiet 2>/dev/null || git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) stash
	@git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) pull --rebase
	@git -C $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) stash pop 2>/dev/null || true
	@echo "📦 Updating brew packages..."
	@brew update && brew upgrade
	@brew bundle install --cleanup --no-upgrade --file ./Brewfile
	@echo "🔗 Re-linking configs..."
	@bash $(INSTALL_SCRIPT)
	@echo "✅ Update complete!"

# Dump currently installed packages to Brewfile to catch manual installs.
dump:
	@brew bundle dump --force --file ./Brewfile
	@echo "📋 Brewfile updated with current packages."

# ==============================================================================
# VALIDATION
# ==============================================================================
# Validate configs before symlinking to prevent broken shell startups.
lint:
	@echo "🔍 Validating configs..."
	@zsh -n $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/.zprofile config/zsh/config/*.zsh) && echo "  ✓ Zsh configs OK" || exit 1
	@python3 -m json.tool config/karabiner/karabiner.json > /dev/null && echo "  ✓ Karabiner JSON OK" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
# Prevents conflicts with any files that might have the same name as a target.
.PHONY: all install clean homebrew brew configs update dump lint
