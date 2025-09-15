# ==============================================================================
# VARIABLES
# ==============================================================================
XDG_CONFIG_HOME ?= ~/.config
XDG_DATA_HOME ?= ~/.local/share
XDG_CACHE_HOME ?= ~/.cache
ZDOTDIR = $(XDG_CONFIG_HOME)/zsh
CURRENT_DIR = $(shell pwd)


# ==============================================================================
# MAIN TARGETS
# ==============================================================================
clean:
	@echo "🧹 Cleaning up symlinks and config files..."
	@rm -f $(HOME)/.gitconfig
	@rm -f $(HOME)/.gitignore
	@rm -f $(HOME)/.vimrc
	@rm -f $(shell bat --config-dir 2>/dev/null)/themes/Catppuccin_Mocha.tmTheme
	@rm -rf $(XDG_CACHE_HOME:-$(HOME)/.cache)/zsh
	@rm -rf $(XDG_CONFIG_HOME)/ghostty
	@rm -rf $(XDG_CONFIG_HOME)/k9s
	@rm -rf $(XDG_CONFIG_HOME)/lsd
	@rm -rf $(XDG_CONFIG_HOME)/nvim
	@rm -rf $(XDG_CONFIG_HOME)/zsh
	@rm -f $(HOME)/.zshenv
	@echo "🧼 Clean complete."

install: homebrew brew git ghostty bat k9s lsd nvim zsh
	@echo "✅ All installations completed!"


# ==============================================================================
# HOMEBREW: SYSTEM & APPLICATION INSTALLATION
# ==============================================================================
BREW_SCRIPT = .brew_install.sh

homebrew: $(BREW_SCRIPT)
	@echo "🍺 Checking/installing Homebrew..."
	@command -v brew >/dev/null 2>&1 || /bin/bash $(BREW_SCRIPT) || (echo "Error: Failed to install Homebrew" && exit 1)

$(BREW_SCRIPT):
	@echo "⏳ Downloading Homebrew install script..."
	@curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' > $@ || (echo "Error: Failed to download Homebrew install script" && exit 1)

brew: Brewfile.lock.json
	@echo "📦 Running brew bundle..."
Brewfile.lock.json: Brewfile
	brew bundle install --cleanup --no-upgrade --file $(CURRENT_DIR)/Brewfile || (echo "Error: brew bundle failed" && exit 1)


# ==============================================================================
# CONFIGURATION SYMLINKING & SETUP
# ==============================================================================

# --- Bat ---
BATTHEMES_DIR = $(shell bat --config-dir 2>/dev/null)/themes
THEME_NAME = Catppuccin_Mocha.tmTheme
THEME_FILE = $(BATTHEMES_DIR)/$(THEME_NAME)

bat: $(THEME_FILE)
	@echo "🦇 Rebuilding bat theme cache..."
	@bat cache --build || (echo "Error: bat cache build failed" && exit 1)

$(THEME_FILE): $(BATTHEMES_DIR)
	@echo "🎨 Downloading Catppuccin Mocha theme for bat..."
	@curl 'https://raw.githubusercontent.com/catppuccin/bat/main/themes/$(subst _,%20,$(THEME_NAME))' > $@ || (echo "Error: Failed to download bat theme" && exit 1)

$(BATTHEMES_DIR):
	@echo "Creating Bat themes directory..."
	@mkdir -p $(BATTHEMES_DIR) || (echo "Error: Failed to create Bat themes directory" && exit 1)

# --- Ghostty ---
ghostty: $(CURRENT_DIR)/ghostty/config
	@echo "👻 Symlinking Ghostty config..."
	@mkdir -p $(XDG_CONFIG_HOME)
	@ln -fhs $(CURRENT_DIR)/ghostty $(XDG_CONFIG_HOME)/ghostty || (echo "Error: Failed to symlink Ghostty config" && exit 1)

# --- Git ---
GITCONFIG_SOURCE_PATH := $(CURRENT_DIR)/git/gitconfig
GITCONFIG_DESTINATION_PATH := $(HOME)/.gitconfig
GITIGNORE_SOURCE_PATH := $(CURRENT_DIR)/git/gitignore
GITIGNORE_DESTINATION_PATH := $(HOME)/.gitignore

git: install-git-config install-git-ignore

install-git-config: $(GITCONFIG_DESTINATION_PATH)
$(GITCONFIG_DESTINATION_PATH): $(GITCONFIG_SOURCE_PATH)
	@echo "🔗 Symlinking .gitconfig..."
	@ln -sf "$<" "$@" || (echo "Error: Failed to symlink .gitconfig" && exit 1)

install-git-ignore: $(GITIGNORE_DESTINATION_PATH)
$(GITIGNORE_DESTINATION_PATH): $(GITIGNORE_SOURCE_PATH)
	@echo "🔗 Symlinking .gitignore..."
	@ln -sf "$<" "$@" || (echo "Error: Failed to symlink .gitignore" && exit 1)

# --- k9s ---
K9S_SOURCE_DIR := $(CURRENT_DIR)/k9s
K9S_SKINS_DIR := $(K9S_SOURCE_DIR)/skins
K9S_SKIN_SENTINEL := $(K9S_SKINS_DIR)/catppuccin-mocha.yaml

k9s: $(K9S_SKIN_SENTINEL)
	@echo "🐾 Symlinking k9s config..."
	@mkdir -p $(XDG_CONFIG_HOME)
	@ln -fhs $(K9S_SOURCE_DIR) $(XDG_CONFIG_HOME)/k9s || (echo "Error: Failed to symlink k9s config" && exit 1)

$(K9S_SKIN_SENTINEL):
	@echo "🎨 Downloading Catppuccin skins for k9s..."
	@mkdir -p $(K9S_SKINS_DIR) || (echo "Error: Failed to create local k9s skins directory" && exit 1)
	@curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C $(K9S_SKINS_DIR) --strip-components=2 k9s-main/dist || (echo "Error: Failed to download k9s skins" && exit 1)

# --- LSD ---
LSD_SOURCE_DIR := $(CURRENT_DIR)/lsd
LSD_COLOR_FILE := $(LSD_SOURCE_DIR)/colors.yml
LSD_CONFIG_FILE := $(LSD_SOURCE_DIR)/config.yml

# The main target the user will call, e.g., `make lsd`
# This depends on the symlinks being correctly in place.
lsd: $(XDG_CONFIG_HOME)/lsd/config.yml $(XDG_CONFIG_HOME)/lsd/colors.yml
	@echo "✅ LSD configuration is set up."

# This rule creates the symlinks in the config directory.
# It depends on the source files existing in your dotfiles repo.
# The '$<' is the source file, and '$@' is the target symlink.
$(XDG_CONFIG_HOME)/lsd/%: $(LSD_SOURCE_DIR)/%
	@echo "🔗 Symlinking LSD config file: $*..."
	@mkdir -p $(XDG_CONFIG_HOME)/lsd
	@ln -fhs "$<" "$@"

# This rule defines how to get the colors.yml file if it doesn't exist.
# It will only run if the file is missing.
$(LSD_COLOR_FILE):
	@echo "🎨 Downloading Catppuccin theme for LSD..."
	@mkdir -p $(LSD_SOURCE_DIR)
	@# Use curl to download the raw YAML file directly.
	@curl -fL "https://raw.githubusercontent.com/catppuccin/lsd/main/theme/catppuccin-mocha.yaml" -o "$(LSD_COLOR_FILE)" || \
		(echo "Error: Failed to download lsd theme" && exit 1)

# --- Neovim ---
nvim: $(CURRENT_DIR)/nvim/init.lua
	@echo "🖋️ Symlinking Neovim config..."
	@mkdir -p $(XDG_CONFIG_HOME)
	@ln -fhs $(CURRENT_DIR)/nvim $(XDG_CONFIG_HOME)/nvim || (echo "Error: Failed to symlink Neovim config" && exit 1)
	@echo "🖋️ Symlinking .vimrc for compatibility..."
	@ln -fhs $(XDG_CONFIG_HOME)/nvim/vimrc $(HOME)/.vimrc || (echo "Error: Failed to symlink .vimrc" && exit 1)

# --- Zsh ---
zsh:
	@echo "🐚 Symlinking Zsh config..."
	@mkdir -p $(XDG_CONFIG_HOME)
	@ln -fhs $(CURRENT_DIR)/zsh $(XDG_CONFIG_HOME)/zsh || (echo "Error: Failed to symlink Zsh config dir" && exit 1)
	@echo "🐚 Symlinking .zshenv..."
	@ln -fhs $(ZDOTDIR)/.zshenv $(HOME)/.zshenv || (echo "Error: Failed to symlink .zshenv" && exit 1)


# ==============================================================================
# PHONY TARGETS
# ==============================================================================
# Prevents conflicts with any files that might have the same name as a target.
.PHONY: bat brew clean git ghostty homebrew install k9s lsd nvim zsh
