# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean
INSTALL_FEDORA       ?= scripts/install-fedora
INSTALL_ARCH         ?= scripts/install-arch
INSTALL_VOID         ?= scripts/install-void
BREW_INSTALLER        = .brew_install.sh

OS     := $(shell uname -s)
# Uniform Linux distro id from /etc/os-release (arch | fedora | void | …).
DISTRO := $(shell . /etc/os-release 2>/dev/null && echo $$ID)

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
	@$(MAKE) linux
else
	@echo "❌ Unsupported OS: $(OS)"; exit 1
endif

# --- Linux: route by /etc/os-release ID ---
linux:
	@case "$(DISTRO)" in \
		arch)   $(MAKE) arch ;; \
		fedora) $(MAKE) fedora ;; \
		void)   $(MAKE) void ;; \
		*) echo "❌ Unsupported Linux distro: '$(DISTRO)' (expected arch/fedora/void)"; exit 1 ;; \
	esac

# --- macOS: Homebrew ---
homebrew: $(BREW_INSTALLER)
	@echo "🍺 Checking/installing Homebrew..."
	@command -v brew >/dev/null 2>&1 || /bin/bash $<

$(BREW_INSTALLER):
	@echo "⏳ Downloading Homebrew install script..."
	@curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' > $@

brew: homebrew packages/Brewfile
	@echo "📦 Running brew bundle..."
	@brew bundle install --no-upgrade --file ./packages/Brewfile

# --- Linux: Fedora (dnf + flatpak + cargo + npm + curl installers) ---
fedora: packages/fedora
	@echo "📦 Installing Fedora packages..."
	@bash $(INSTALL_FEDORA)

# --- Linux: Arch (pacman + AUR/paru + npm + curl installers) ---
arch: packages/arch
	@echo "📦 Installing Arch packages..."
	@bash $(INSTALL_ARCH)

# --- Linux: Void (xbps + runit services) ---
void: packages/void
	@echo "📦 Installing Void packages..."
	@bash $(INSTALL_VOID)

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
	@brew bundle install --no-upgrade --file ./packages/Brewfile
else ifeq ($(OS),Linux)
	@case "$(DISTRO)" in \
		arch) echo "📦 Updating pacman packages..."; \
			sudo pacman -Syu --noconfirm; \
			command -v paru >/dev/null 2>&1 && paru -Sua --noconfirm || true; \
			bash $(INSTALL_ARCH) ;; \
		fedora) echo "📦 Updating dnf packages..."; \
			sudo dnf upgrade -y; \
			flatpak update --user -y || true; \
			bash $(INSTALL_FEDORA) ;; \
		void) echo "📦 Updating xbps packages..."; \
			sudo xbps-install -Su || true; \
			flatpak update --user -y || true; \
			bash $(INSTALL_VOID) ;; \
		*) echo "❌ Unsupported Linux distro: '$(DISTRO)'"; exit 1 ;; \
	esac
endif
	@echo "🔗 Re-linking configs..."
	@bash $(INSTALL_SCRIPT)
	@echo "✅ Update complete!"

# Dump currently installed packages — only meaningful on macOS (Brewfile).
dump:
ifeq ($(OS),Darwin)
	@brew bundle dump --force --file ./packages/Brewfile
	@echo "📋 Brewfile updated with current packages."
else
	@echo "ℹ️  dump is macOS-only (Brewfile). Edit packages/fedora by hand."
endif

# ==============================================================================
# VALIDATION
# ==============================================================================
lint:
	@echo "🔍 Validating configs..."
	@zsh -n $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/.zprofile config/zsh/config/*.zsh) && echo "  ✓ Zsh configs OK" || exit 1
	@python3 -m json.tool config/karabiner/karabiner.json > /dev/null && echo "  ✓ Karabiner JSON OK" || exit 1
	@bash -n scripts/lib/common.sh $(INSTALL_SCRIPT) $(CLEAN_SCRIPT) $(INSTALL_FEDORA) $(INSTALL_ARCH) $(INSTALL_VOID) && echo "  ✓ Install scripts OK" || exit 1
	@bash -n packages/fedora packages/arch packages/void && echo "  ✓ Package manifests OK" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
.PHONY: all install clean homebrew brew fedora arch void linux packages configs update dump lint
