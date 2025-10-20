# ==============================================================================
# PREAMBLE - Get hostname for conditional installs
# ==============================================================================
hostname = `hostname`.strip


# ==============================================================================
# CORE SYSTEM & COMMAND-LINE INTERFACE (CLI) TOOLS
# ==============================================================================
# Essential utilities for file management, searching, and development.

brew "bat"               # A cat(1) clone with wings.
brew "bat-extras"        # Extra scripts for bat.
brew "cmake"             # Cross-platform build system.
brew "eza"               # A modern replacement for 'ls'.
brew "fd"                # A simple, fast and user-friendly alternative to 'find'.
brew "fzf"               # A command-line fuzzy finder.
brew "gh"                # GitHub's official command-line tool.
brew "glab"              # GitLab's official command-line tool.
brew "git"               # Distributed revision control system.
brew "gnutls"            # A secure communications library implementing SSL, TLS and DTLS.
brew "node"              # JavaScript runtime.
brew "openssh"           # OpenBSD's Secure Shell server.
brew "ripgrep"           # A line-oriented search tool that recursively searches your current directory.
brew "vivid"             # A generator for LS_COLORS with themes.
brew "watch"             # Executes a program periodically, showing output fullscreen.
brew "wget"              # A free utility for non-interactive download of files from the Web.


# ==============================================================================
# TERMINAL & SHELL ENHANCEMENTS
# ==============================================================================
# Terminals, shells, and tools that improve the command-line experience.

cask "ghostty"           # A modern GPU-accelerated terminal emulator.

brew "hyperfine"

brew "antidote"          # A Zsh plugin manager.
brew "atuin"             # Magical shell history.
brew "btop"              # A modern resource monitor.
brew "fastfetch"         # A neofetch-like tool for fetching system information.
brew "lazygit"
brew "pyenv"             # Python version management.
brew "starship"          # The minimal, blazing-fast, and infinitely customizable prompt.
brew "zoxide"            # A smarter cd command.


# ==============================================================================
# DEVELOPMENT & EDITORS
# ==============================================================================
# Code editors, fonts, and related development tools.

# --- Editors ---
brew "neovim"
cask "zed"

# --- Editor Dependencies ---
brew "tree-sitter"
brew "tree-sitter-cli"

# --- Fonts ---
cask "font-commit-mono-nerd-font"
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-maple-mono-nf"
cask "font-monaspace"
cask "sf-symbols"

# --- Languages ---
brew "zig"
brew "go"

# ==============================================================================
# DESKTOP APPLICATIONS & UTILITIES
# ==============================================================================

# --- Browsers ---
cask "zen"

# --- Productivity ---
cask "1password"
cask "1password-cli"
cask "chatgpt"
cask "keyboardcleantool"
cask "nordvpn"
cask "obsidian"

# --- macOS Utilities ---
cask "alfred"
cask "appcleaner"
cask "jordanbaird-ice"      # A modern menu bar manager for macOS.
cask "karabiner-elements"   # A powerful and stable keyboard customizer.
cask "keka"                 # A free file archiver for macOS.
cask "lulu"                 # A free macOS firewall.
cask "pearcleaner"
cask "rectangle-pro"        # Window management.

tap "nikitabobko/tap"
cask "aerospace"

tap "FelixKratz/formulae"
brew "borders"
brew "sketchybar"
cask "font-sketchybar-app-font"

# --- Messengers ---
cask "signal"

# --- Entertainment ---
cask "philips-hue-sync"
cask "spotify"
cask "steam"
cask "stremio"

# --- Mac App Store Apps ---
brew "mas" # Command-line interface for the Mac App Store.
mas "Startup Manager", id: 1296723195
mas "Telegram Messenger", id: 747648890
mas "WhatsApp Messenger", id: 310633997


# ==============================================================================
# WORK-SPECIFIC SETUP
# ==============================================================================
# These packages will only be installed on machines with a hostname
# starting with 'PC-'.

if hostname.start_with?('PC-')
  # --- Developer Tools ---
  tap "dbt-labs/dbt-cli"
  brew "dbt-labs/dbt-cli/dbt"
  tap "hashicorp/tap"
  brew "hashicorp/tap/terraform"
  brew "pre-commit"
  brew "ruff"
  brew "uv"

  # --- Security / Cryptography ---
  brew "gnupg"
  brew "pinentry-mac"

  # --- Kubernetes ---
  brew "helm"
  brew "k9s"
  brew "krew"
  brew "kubectx"

  # --- Google Cloud ---
  cask "gcloud-cli"

  # --- Work Apps (Mac App Store) ---
  mas "Bitwarden", id: 1352778147
  mas "Slack", id: 803453959
end
