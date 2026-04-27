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
brew "eza"               # A modern replacement for 'ls'.
brew "fd"                # A simple, fast and user-friendly alternative to 'find'.
brew "delta"             # A syntax-highlighting pager for git, diff, and grep output.
brew "fzf"               # A command-line fuzzy finder.
brew "jq"                # A lightweight command-line JSON processor.
brew "gh"                # GitHub's official command-line tool.
brew "glab"              # GitLab's official command-line tool.
brew "git"               # Distributed revision control system.
brew "git-machete"       # Manage stacked branches and PR chains.
# node, go, and python are managed by mise
brew "ripgrep"           # A line-oriented search tool that recursively searches your current directory.
brew "stow"              # Symlink farm manager for dotfiles.
brew "tealdeer"          # Fast tldr client for quick command examples.
brew "vivid"             # A generator for LS_COLORS with themes.
brew "hyperfine"         # A command-line benchmarking tool.
brew "watch"             # Executes a program periodically, showing output fullscreen.


# ==============================================================================
# TERMINAL & SHELL ENHANCEMENTS
# ==============================================================================
# Terminals, shells, and tools that improve the command-line experience.

cask "ghostty"           # A modern GPU-accelerated terminal emulator.

brew "antidote"          # A Zsh plugin manager.
brew "fastfetch"         # A neofetch-like tool for fetching system information.
brew "mise"              # Polyglot version manager (replaces pyenv, nvm, etc.).
brew "starship"          # The minimal, blazing-fast, and infinitely customizable prompt.
brew "zoxide"            # A smarter cd command.

# TUI's
brew "btop"
brew "lazygit"
brew "yazi"

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
cask "font-jetbrains-mono-nerd-font"

# --- Languages ---
brew "zig"

# --- AI ---
cask "chatgpt"
cask "claude-code"
cask "claude"
brew "gemini-cli"
brew "ollama"
brew "opencode"

# ==============================================================================
# DESKTOP APPLICATIONS & UTILITIES
# ==============================================================================

# --- Browsers ---
cask "zen"

# --- Productivity ---
cask "Bitwarden"
brew "bitwarden-cli"

cask "keyboardcleantool"
cask "nordvpn"
cask "obsidian"

# --- macOS Utilities ---
cask "alfred"
cask "keepingyouawake"
cask "appcleaner"
cask "jordanbaird-ice"      # A modern menu bar manager for macOS.
cask "karabiner-elements"   # A powerful and stable keyboard customizer.
cask "keka"                 # A free file archiver for macOS.
cask "lulu"                 # A free macOS firewall.
cask "pearcleaner"
cask "rectangle-pro"        # Window management.

# --- Messengers ---
cask "signal"

# --- Entertainment ---
cask "philips-hue-sync"
cask "spotify"
cask "steam"
cask "stremio"
cask "equinox"

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
  brew "parallel"
  brew "yq"

  # --- Git ---
  brew "gnupg"
  brew "pinentry-mac"

  # --- Kubernetes ---
  brew "helm"
  brew "k9s"
  brew "krew"
  brew "kubectx"
  cask "docker-desktop"

  # --- Google Cloud ---
  cask "gcloud-cli"

  # --- Work Apps (Mac App Store) ---
  mas "Slack", id: 803453959
end
