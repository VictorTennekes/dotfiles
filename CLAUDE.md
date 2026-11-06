# Dotfiles

Cross-platform dotfiles (macOS + Fedora Linux/niri) managed with GNU
Stow; packages via Homebrew (`packages/Brewfile`) on macOS and dnf
(`packages/fedora.txt`, official repos + Terra) on Fedora.

## Structure

- `config/` — shared app configs stowed to `~/.config/` on both OSes
  (zsh, git, nvim, ghostty, btop, fastfetch, tmux)
- `config-macos/` — macOS-only (ghostty `platform`, swiftbar)
- `config-linux/` — Linux-only (niri, waybar, swaync, swayosd, swaylock,
  swayidle, fuzzel, foot, yazi, ghostty `platform`)
- `system-linux/` — `/etc` files that `scripts/setup` installs on Fedora
  (zram, sysctl, journald, dnf without weak deps, the Tailscale repo, SDDM,
  NetworkManager Wi-Fi backend = iwd) and
  the polkit rule that lets the Waybar toggle start/stop tailscaled. Setup
  keeps a manifest and removes files deleted here from `/etc`, so never put
  a package-owned file here
- `home/` — home-level dotfiles stowed to `~/` (.zshenv). `home/.agents/`
  is the tool-agnostic agent config: `AGENTS.md` (global instructions) and
  `skills/` (Agent Skills layout, `~/.agents/skills`). `home/.claude/` is
  Claude Code only: `settings.json` (portable keys; work/auto-mode context
  lives in the work repo's `.claude/settings.local.json`) and a `CLAUDE.md`
  that just imports `~/.agents/AGENTS.md`. `~/.claude` stays a real dir
  (Claude writes state there); `scripts/install` links each skill into
  `~/.claude/skills/`
- `packages/` — `Brewfile` (work packages gated behind `~/.work-laptop`),
  `fedora.txt` (curated, commented; `make dump` on Fedora only lists
  what's missing, never overwrites). Fedora has no AUR: prefer the official
  repos, then Terra (Tailscale comes from its vendor repo, which is much
  newer); the only things installed outside dnf are the Bitwarden
  AppImage (checked against its release's sha512) and
  git clones in setup (zsh plugins; sddm-astronaut-theme, pinned to a
  commit in `ASTRONAUT_REV`)
- Language runtimes come from the package manager on both OSes, one copy
  each: node, python3, uv (project Pythons, `uv tool install` for Python
  CLIs), go (mason builds sqls with it). No version manager
- `scripts/` — `setup` (guided install + `--check` doctor, branches on
  OS; also clones `config/nvim`, its own repo), `install` (stow `config` +
  `config-<os>` + `home`), `clean`, `nvim-update.lua` (headless vim.pack,
  treesitter parser and Mason sync for `make update`, prints only changes
  and errors),
  `macos-defaults`, `tpm-enroll` (TPM unlock for the LUKS root; run by hand,
  never from setup, and kept generic: no device names)
- `Makefile` — `install` (runs `scripts/setup`), `doctor`, `update` (pull,
  packages, zsh plugins, nvim plugins + Mason tools, re-link; the zsh `up`
  runs it), `dump` (lists
  unlisted packages, never rewrites a list), `lint` (also CI:
  `.github/workflows/lint.yml`), `clean`, `brew`/`brew-sync` (macOS;
  `brew-sync` removes unlisted packages); OS-specific targets via
  `ifeq ($(OS),Darwin)`

## Cross-platform rules

- One version per shared config. Prefer "use it if it exists" checks
  (`(( $+commands[pbcopy] ))`) over OS branches; `up` is the only OS
  `case` in zsh.
- Per-machine values (signing key, gh credential helper with gh's
  absolute path) go in `~/.gitconfig.local`, written by `scripts/setup`.
- A tool used on only one OS goes in that OS's `config-<os>/`. Ghostty is
  shared: `config/ghostty/config` loads the OS's `platform` file last.
- Test changes to shared files on both machines (`make lint`,
  `make doctor`). The Mac is reachable from the Linux laptop as
  `ssh mac` over Tailscale.
- Disk/boot setup (LUKS, TPM, GRUB, dracut) is never automated; it's the
  README's Fedora boot notes.
- Keep the Linux install minimal: dnf runs with weak deps off, and nothing
  goes in that isn't in `packages/fedora.txt`.

## Shell (Zsh)

- Entry: `.zshrc` sources modular configs from
  `config/zsh/config/`
- Plugins: git clones of `zsh_plugins.txt` in `~/.local/share/zsh-plugins`
  (setup clones, `make update` pulls), loaded by `plugins.zsh`; all deferred via
  zsh-defer (the list's first entry). No framework: compinit runs in
  `plugins.zsh` from a cached dump, rebuilt when fpath or one of its dirs changes
- Tool inits (fzf, zoxide) cached in `~/.cache/zsh/` to avoid subprocess
  spawns; starship is called directly by the async prompt (`prompt.zsh`), no
  `starship init`
- zsh 5.9 stops servicing `zle -F` handlers once a widget or compinit runs
  inside one, which kills the async prompt: compinit runs before the first
  prompt, zsh-defer tasks use `-psz`, autosuggestions stays sync
  (`plugins.zsh`)
- Custom functions use zsh autoload (parsed on first call)
- Exports (incl. PATH), history, aliases, completions, integrations,
  prompt and plugins are separate files

## Neovim

- `init.lua` (options, keymaps, autocmds, ordered plugin list) plus one file
  per plugin in `config/nvim/lua/plugins/`; no kickstart tutorial code
- Built-in `vim.pack` for plugins (`nvim-pack-lock.json`); `lua/later.lua`
  defers plugins to their first event (no lazy loading in vim.pack).
  nvim-treesitter on `main` (listed parsers always installed, others on
  first open). Mason + mason-tool-installer for LSP/tools; servers
  enabled with native `vim.lsp.enable` (no mason-lspconfig)
- Snacks.nvim handles picker, explorer, indent guides, notifier, UI
- Neovim's built-in ui2 (experimental) handles cmdline/message UI; `init.lua`
  floats its cmdline window (no ui2 option for that) with `cmdheight=0`
- LSPs: basedpyright, ruff (Python), lua_ls, terraformls, sqls
- Formatters via conform: stylua, ruff, sqlfluff

## Linux desktop (niri)

- niri config in `config-linux/niri/config.kdl` (one file; `niri validate`
  checks it, niri reloads on save); scripts (power menu, screenshots) in
  `config-linux/niri/scripts/`
- swayidle (`swayidle -w`, started by niri) dims, locks with swaylock,
  turns screens off and suspends
- Low-power choices: small shadow, swaybg, foot server over Ghostty; X11
  only on demand
  (xwayland-satellite, a hard dependency of Fedora's niri)
- Super = window management; Alt+Shift+3/4/5 = screenshots (macOS
  numbers)
- Clipboard history (cliphist) keeps 100 entries and is wiped at every
  login: password managers copy secrets into it

## Conventions

- Catppuccin Mocha theme everywhere (Linux accent: mauve → peach)
- XDG Base Directory compliance
- Bitwarden for passwords. Git uses one key file per machine
  (`~/.ssh/id_ed25519`, auth + signing, no passphrase) so remote
  sessions can use it; Secure Enclave keys can't. Its signing key
  path lives in `~/.gitconfig.local`, written by `scripts/setup`.
