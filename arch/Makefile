# ==============================================================================
# VARIABLES
# ==============================================================================
# Assume scripts are in a 'scripts' subdirectory
INSTALL_SCRIPT ?= scripts/install
CLEAN_SCRIPT ?= scripts/clean

# ==============================================================================
# MAIN TARGETS
# ==============================================================================
# Default target when running `make`
all: install

# Main installation orchestrator: first packages, then configs.
install: configs
	@echo "✅ All setup complete!"

# The clean target now calls the clean script and removes downloaded files.
clean:
	@echo "🧹 Cleaning up dotfiles..."
	@bash $(CLEAN_SCRIPT)
	@echo "🧼 Clean complete."

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
.PHONY: all install clean configs
