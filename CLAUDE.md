# Dotfiles

macOS dotfiles managed with Homebrew and symlinks.
All configs live in `config/` and are symlinked to
`~/.config/` via `scripts/install`.

## Structure

- `Brewfile` — all packages, casks, and Mac App Store
  apps. Work packages gated behind `PC-` hostname.
- `config/` — app configs
  (zsh, git, nvim, ghostty, btop, k9s, karabiner)
- `scripts/install` — symlinks configs, clones nvim
- `scripts/clean` — removes all symlinks
- `Makefile` — `install`, `update`, `dump`, `clean`

## Shell (Zsh)

- Entry: `.zshrc` sources modular configs from
  `config/zsh/config/`
- Plugins via antidote, all deferred for performance
- Tool inits (fzf, zoxide, starship) are cached in
  `~/.cache/zsh/` to avoid subprocess spawns
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
