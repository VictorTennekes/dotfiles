# --- Homebrew ---
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- App Configurations ---
export BAT_THEME="Catppuccin_Mocha"
export FZF_DEFAULT_COMMAND='fd --type f'
export STARSHIP_CONFIG="$HOME/.config/zsh/starship.toml"

# --- Terminal Colors ---
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
