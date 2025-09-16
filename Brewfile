# Core Configuration
hostname = `hostname`.strip

# Fonts
cask "font-commit-mono-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-monaspace"
cask "font-maple-mono-nf"
cask "font-maple-mono-normal-nf"

# Terminals
cask "ghostty"

# Terminal Tools (CLI Utilities)
brew "bat"
brew "eza"
brew "fzf"
brew "gh"
brew "git"
brew "gnutls"
brew "neovim"
brew "node"
brew "openssh"
brew "watch"
brew "wget"

# Shell Enhancements
brew "antidote"
brew "atuin"
brew "starship"
brew "zoxide"
brew "pyenv"

# Browsers
cask "zen"

# macOS Utilities
cask "alfred"
cask "jordanbaird-ice"
cask "karabiner-elements"
cask "keka"

# Security
cask "lulu"

# Window Management
cask "rectangle-pro"

# macOS Maintenance
cask "appcleaner"

# Productivity Applications
cask "1password"
cask "1password-cli"
cask "chatgpt"
cask "keyboardcleantool"
cask "nordvpn"
cask "obsidian"
brew "mas"

# Other Applications
cask "philips-hue-sync"
cask "spotify"
cask "steam"

# Mac App Store Applications
mas "Startup Manager", id: 1296723195
mas "Telegram", id: 747648890
mas "WhatsApp", id: 310633997

# Work-Specific Packages
if hostname.start_with?('PC-')
  # Security / Cryptography
  brew "gnupg"
  brew "pinentry-mac"

  # DBT
  tap "dbt-labs/dbt-cli"
  brew "dbt-labs/dbt-cli/dbt"

  # Terraform
  tap "hashicorp/tap"
  brew "hashicorp/tap/terraform"

  # Docker & Kubernetes
  cask "docker-desktop"
  brew "helm"
  brew "krew"
  brew "kubectx"
  brew "k9s"

  # Tools
  brew "pre-commit"
  brew "ruff"
  brew "uv"

  # Google Cloud
  cask "gcloud-cli"

  # Work Apps - Mac App Store
  mas "Bitwarden", id: 1352778147
  mas "Slack", id: 803453959
end
