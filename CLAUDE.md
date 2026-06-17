# Dotfiles

Cross-platform dotfiles managed with GNU Stow. Configs are
plain files (in `config/`) stowed identically on every OS;
each platform supplies its own packages. This keeps the repo
portable — macOS uses Homebrew (`packages/Brewfile`), Linux is
NixOS-only and installs packages declaratively (`nixos/`) but
**still stows the same `config/` files** (no Home Manager).

Hosts: `r2d2` (Framework 13 AMD — the Linux/tinkering box),
plus the macOS daily driver (M1 MacBook Pro 16").

## Structure

- `config/` — app configs stowed to `~/.config/`, shared
  across all platforms (zsh, git, nvim, ghostty, btop, k9s,
  lazygit, yazi, bat, mise, fastfetch)
- `home/` — home-level dotfiles stowed to `~/` (.zshenv)
- `packages/` — `Brewfile` (macOS package manifest). Work
  packages gated behind `PC-` hostname.
- `darwin/` — macOS-only configs (karabiner)
- `nixos/` — declarative NixOS config for r2d2 (flake +
  disko + GNOME); see `nixos/README.md` for the install
  runbook. `nixos/packages.nix` is the Linux package
  manifest; dotfiles are still stowed from `config/`.
- `scripts/` — `install` (stow + nvim), `clean`,
  `macos-defaults`
- `Makefile` — `install`, `update`, `dump`, `clean`

## Shell (Zsh)

- Entry: `.zshrc` sources modular configs from
  `config/zsh/config/`
- Plugins via antidote, all deferred for performance
- Tool inits (fzf, zoxide, starship, mise) cached in
  `~/.cache/zsh/` to avoid subprocess spawns
- Custom functions use zsh autoload (parsed on first call)
- mise for polyglot version management (python, node, etc.)
- Exports, paths, aliases, functions, completions,
  history are separate files

## Neovim

- Based on kickstart.nvim, customized in
  `config/nvim/lua/custom/`
- Lazy.nvim for plugin management, Mason for LSP/tools
- Snacks.nvim handles picker, explorer, UI
- Noice.nvim handles cmdline/message UI
- LSPs: basedpyright, ruff (Python), lua_ls
- Formatters via conform: stylua, ruff, sqlfluff

## Conventions

- Catppuccin Mocha theme everywhere
- XDG Base Directory compliance
- Bitwarden for secrets and SSH agent
