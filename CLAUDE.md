# Dotfiles

Cross-platform dotfiles (macOS + Arch Linux/Hyprland) managed with GNU
Stow; packages via Homebrew (`packages/Brewfile`) on macOS and
pacman + paru (`packages/arch.txt`, `packages/aur.txt`) on Arch.

## Structure

- `config/` — shared app configs stowed to `~/.config/` on both OSes
  (zsh, git, nvim, btop, k9s, yazi, bat, mise, fastfetch, tmux)
- `config-macos/` — macOS-only (ghostty, swiftbar)
- `config-linux/` — Linux-only (hypr, waybar, swaync, swayosd, fuzzel,
  foot)
- `system-linux/` — `/etc` files that `scripts/setup` installs on Arch
  (zram, sysctl, journald, iwd, SDDM)
- `home/` — home-level dotfiles stowed to `~/` (.zshenv)
- `packages/` — `Brewfile` (work packages gated behind `~/.work-laptop`),
  `arch.txt`, `aur.txt` (curated, commented; `make dump` on Arch only
  lists what's missing, never overwrites)
- `scripts/` — `setup` (guided install + `--check` doctor, branches on
  OS), `install` (stow `config` + `config-<os>` + nvim), `clean`,
  `macos-defaults`
- `Makefile` — `install` (runs `scripts/setup`), `doctor`, `update`,
  `dump`, `lint`, `clean`; OS-specific targets via `ifeq ($(OS),Darwin)`

## Cross-platform rules

- One version per shared config. Prefer "use it if it exists" checks
  (`(( $+commands[pbcopy] ))`, Homebrew vs `~/.local/share/antidote`)
  over OS branches; `up` is the only OS `case` in zsh.
- Per-machine values (signing key, gh credential helper with gh's
  absolute path) go in `~/.gitconfig.local`, written by `scripts/setup`.
- A tool used on only one OS goes in that OS's `config-<os>/`.
- Test changes to shared files on both machines (`make lint`,
  `make doctor`). The Mac is reachable from the Linux laptop as
  `ssh mac` over Tailscale.
- Disk/boot setup (LUKS, TPM, Limine, mkinitcpio) is never automated;
  it's the README's Arch boot checklist.

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

## Linux desktop (Hyprland)

- Hyprland 0.56+ Lua config split into modules in `config-linux/hypr/`
  (API stubs: `/usr/share/hypr/stubs/hl.meta.lua`)
- Low-power choices: blur `xray`, short animations, swaybg over
  hyprpaper, foot server over Ghostty, XWayland off
- Super = window management; Alt+Shift+3/4/5 = screenshots (macOS
  numbers)

## Conventions

- Catppuccin Mocha theme everywhere (Linux accent: mauve → peach)
- XDG Base Directory compliance
- Bitwarden for passwords. Git uses one plain key file per
  machine (`~/.ssh/id_ed25519`, auth + signing) so it works
  unattended while the screen is locked (Secure Enclave keys
  don't). Its signing key path lives in `~/.gitconfig.local`,
  written by `scripts/setup`.
