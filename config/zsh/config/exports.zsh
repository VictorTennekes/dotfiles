# Guard against double-sourcing within a shell. Must NOT be exported: an
# exported flag leaks into every child shell, so a stale ancestor (started
# before this file last changed) would make new shells skip these exports
# entirely — silently serving outdated config until full logout.
[[ -n "$_EXPORTS_SOURCED" ]] && return
typeset -g _EXPORTS_SOURCED=1

# --- Homebrew (avoid eval fork by hardcoding prefix) ---
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -x /usr/local/bin/brew ]]; then
    export HOMEBREW_PREFIX="/usr/local"
  fi
  if [[ -n "$HOMEBREW_PREFIX" ]]; then
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin${PATH+:$PATH}"
    export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
  fi
fi

# --- Bitwarden SSH agent ---
# Bitwarden's macOS socket path has flip-flopped across versions (flat
# $HOME path since 2026.7.0 per app.log, Containers path again on later
# updates on this machine) — whichever path isn't currently in use is
# left behind as a dead orphaned socket file, and `-S` can't tell dead
# from live. Probe each candidate and keep whichever actually answers
# (ssh-add exit 2 == no agent listening there).
for _bw_sock in \
  "$HOME/.bitwarden-ssh-agent.sock" \
  "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"; do
  if [[ -S "$_bw_sock" ]]; then
    SSH_AUTH_SOCK="$_bw_sock" command ssh-add -l &>/dev/null
    [[ $? -ne 2 ]] && { export SSH_AUTH_SOCK="$_bw_sock"; break; }
  fi
done
unset _bw_sock

# --- App Configurations ---
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
export K9S_CONFIG_DIR="$HOME/.config/k9s"
export MISE_CONFIG_DIR="$HOME/.config/mise"
export STARSHIP_CONFIG="$HOME/.config/zsh/starship.toml"

# --- Terminal Colors (cached to avoid vivid fork on every login) ---
export CLICOLOR=1
if [[ -z "$LS_COLORS" ]]; then
  _vivid_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/ls_colors.zsh"
  if (( $+commands[vivid] )); then
    if [[ ! -s "$_vivid_cache" || "${commands[vivid]}" -nt "$_vivid_cache" ]]; then
      vivid generate catppuccin-mocha 2>/dev/null > "$_vivid_cache"
    fi
    export LS_COLORS="$(<$_vivid_cache)"
  fi
  unset _vivid_cache
fi
