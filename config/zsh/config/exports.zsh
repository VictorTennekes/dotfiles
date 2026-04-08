# --- Homebrew ---
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Bitwarden ---
export SSH_AUTH_SOCK="/Users/victortennekes/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"

# --- App Configurations ---
export BAT_THEME="Catppuccin_Mocha"
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
export STARSHIP_CONFIG="$HOME/.config/zsh/starship.toml"

# --- Terminal Colors ---
export CLICOLOR=1
if [[ -z "$LS_COLORS" ]]; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

export GOOGLE_CLOUD_PROJECT="com-ridedott-data"
