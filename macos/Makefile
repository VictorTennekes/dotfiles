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
# PHONY TARGETS
# ==============================================================================
# Prevents conflicts with any files that might have the same name as a target.
.PHONY: all install clean homebrew brew configs
