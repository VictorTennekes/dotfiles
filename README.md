# Dotfiles

My personal macOS configuration, managed with Make and structured for
XDG compliance. This setup automates the installation of applications
and symlinking of configuration files for a clean and reproducible environment.

---

## What's Inside?

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote)
for plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) via a `Brewfile`.
- **Terminal:** [Ghostty](https://ghostty.org/) with Catppuccin Mocha theme.
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs,
commit signing via Bitwarden SSH agent.
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `lazygit`, `btop`, `yazi`, `k9s`.
- **Editor:** Neovim, managed separately at
[victortennekes/nvim](https://github.com/victortennekes/nvim).

---

## Installation

### Prerequisites

- Git
- macOS Command Line Tools (`xcode-select --install`)

### Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/victortennekes/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the installer:**

   ```bash
   make install
   ```

   This will:
   - Install Homebrew if not present.
   - Install all packages from the `Brewfile`.
   - Symlink all configs to `~/.config/`.

---

## Usage

| Command | Description |
|---|---|
| `make install` | Full setup: brew + symlinks |
| `make update` | Pull dotfiles, update brew, re-link |
| `make dump` | Export current brew packages to Brewfile |
| `make clean` | Remove all symlinks |

---

## Repository Structure

```txt
.dotfiles/
├── Brewfile        # Homebrew packages, casks, and Mac App Store apps
├── Makefile        # Setup orchestrator
├── config/         # App configs, symlinked to ~/.config/
│   ├── bat/
│   ├── btop/
│   ├── ghostty/
│   ├── git/
│   ├── k9s/
│   ├── karabiner/
│   └── zsh/
└── scripts/
    ├── install     # Symlink creation
    └── clean       # Symlink removal
```
