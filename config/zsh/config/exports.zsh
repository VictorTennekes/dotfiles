# Guard is not exported, or a child shell started before an edit would skip this file.
[[ -n "$_EXPORTS_SOURCED" ]] && return
typeset -g _EXPORTS_SOURCED=1

export EDITOR=nvim
export BAT_THEME="Catppuccin Mocha"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#45475a \
  --tmux center \
  --height=60% --layout=reverse --border"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export STARSHIP_CONFIG="$HOME/.config/zsh/starship.toml"
export T3CODE_TELEMETRY_ENABLED=false

# ls_colors is `vivid generate catppuccin-mocha` output, committed so neither
# machine needs vivid; regenerate it with a throwaway vivid (`cargo install vivid`).
# Overrides the distro default (Fedora's /etc/profile.d/colorls.sh sets one).
[[ -r "$ZDOTDIR/ls_colors" ]] && export LS_COLORS="$(<$ZDOTDIR/ls_colors)"

# (N/): only directories that exist. node, python and go come from Homebrew or
# dnf; projects pin Python with uv. Homebrew without `brew shellenv` (a fork);
# man finds its pages via PATH. /usr/local/bin (Docker, VS Code CLIs): macOS
# path_helper no longer runs.
typeset -gU path
path=($HOME/.cargo/bin(N/) $HOME/go/bin(N/) $HOME/.krew/bin(N/) $HOME/bin(N/) $HOME/.local/bin(N/) /opt/homebrew/{bin,sbin}(N/) /usr/local/bin(N/) $path)
