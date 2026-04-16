# Dotfiles

macOS dotfiles managed with Homebrew and GNU Stow.

## Structure

- `Brewfile` — all packages, casks, and Mac App Store
  apps. Work packages gated behind `PC-` hostname.
- `config/` — app configs stowed to `~/.config/`
  (zsh, git, nvim, ghostty, btop, k9s, karabiner)
- `home/` — home-level dotfiles stowed to `~/`
  (.zshenv)
- `scripts/install` — stow configs, clone nvim
- `scripts/clean` — unstow all symlinks
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
