export EDITOR=nvim
# Colours by ANSI index, not hex, so the terminal palette decides them: Noctalia's
# on Linux, Catppuccin Mocha in macOS Ghostty
export BAT_THEME="base16"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS=" \
  --color=fg:-1,bg:-1,fg+:-1,bg+:black,selected-bg:black \
  --color=hl:yellow,hl+:yellow,pointer:yellow,spinner:yellow \
  --color=prompt:cyan,marker:cyan,info:bright-black,header:blue,border:bright-black \
  --tmux center \
  --height=60% --layout=reverse --border"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export T3CODE_TELEMETRY_ENABLED=false

# ls_colors is GNU dircolors' built-in database (`TERM=xterm-256color dircolors
# -b` with no file): 16-colour codes only, so `ls` and eza follow the palette too.
# Overrides the distro default (Fedora's /etc/profile.d/colorls.sh sets one).
[[ -r "$ZDOTDIR/ls_colors" ]] && export LS_COLORS="$(<$ZDOTDIR/ls_colors)"

# (N/): only directories that exist. node, python and go come from Homebrew or
# dnf; projects pin Python with uv. Homebrew without `brew shellenv` (a fork);
# man finds its pages via PATH. /usr/local/bin (Docker, VS Code CLIs): macOS
# path_helper no longer runs.
typeset -gU path
path=($HOME/.cargo/bin(N/) $HOME/go/bin(N/) $HOME/.krew/bin(N/) $HOME/bin(N/) $HOME/.local/bin(N/) /opt/homebrew/{bin,sbin}(N/) /usr/local/bin(N/) $path)
