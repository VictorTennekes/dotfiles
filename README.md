# Dotfiles

Personal macOS configuration, managed with Make and GNU Stow.
XDG Base Directory compliant throughout.

---

## What's Inside

- **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote) for
  plugin management and [Starship](https://starship.rs/) prompt.
- **Package Manager:** [Homebrew](https://brew.sh/) (`packages/Brewfile`).
- **Terminal:** [Ghostty](https://ghostty.org/) with Catppuccin Mocha theme.
- **Editor:** Neovim, managed separately at
  [victortennekes/nvim](https://github.com/victortennekes/nvim).
- **Git:** [Delta](https://github.com/dandavison/delta) for diffs, commit
  signing with Secure Enclave keys via [Secretive](https://github.com/maxgoedjen/secretive).
- **Core Utils:** `bat`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`, `jq`.
- **TUIs:** `btop`, `yazi`, `k9s`, `fastfetch`.

---

## Installation

### Prerequisites

- Git
- Command Line Tools (`xcode-select --install`)

### Steps

```bash
git clone https://github.com/victortennekes/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

Work-only packages (dbt, terraform, k9s, Slack, …) are gated by a marker
file, `~/.work-laptop`. Create it once on the work machine: `touch ~/.work-laptop`.

---

## Usage

| Command        | Description                                       |
|----------------|---------------------------------------------------|
| `make install` | Guided setup: packages, links, keys, remote access |
| `make doctor`  | Same checks as install, report only               |
| `make update`  | Pull dotfiles, update packages, re-link configs   |
| `make dump`    | Export current brew packages to Brewfile          |
| `make lint`    | Validate zsh, JSON, and install scripts           |
| `make clean`   | Remove all stow symlinks                          |

---

## Repository Structure

```txt
.dotfiles/
├── packages/
│   └── Brewfile      # brew, casks, mas
├── config/           # App configs → ~/.config/
│   ├── bat/
│   ├── btop/
│   ├── fastfetch/
│   ├── ghostty/
│   ├── git/
│   ├── k9s/
│   ├── karabiner/
│   ├── mise/
│   ├── nvim/
│   ├── tmux/
│   ├── yazi/
│   └── zsh/
├── home/             # Home-level dotfiles → ~/
│   └── .zshenv
├── scripts/
│   ├── setup         # Guided install / --check doctor
│   ├── install       # Symlink dotfiles via stow
│   ├── clean         # Remove stow symlinks
│   └── macos-defaults # Apply macOS system defaults
└── Makefile
```

---

## Notes

- **Clipboard.** The `clip` zsh function uses `pbcopy`, or OSC 52 over SSH
  so copies land on the local terminal.
- **SSH agent.** Secretive. `daily` key needs Touch ID per use; `remote`
  key (no approval) is used automatically in SSH and herdr sessions.
- **Keyboard remapping.** Karabiner (`config/karabiner/`).
- **macOS defaults.** Run `scripts/macos-defaults` after first install to
  apply sensible system preferences.
