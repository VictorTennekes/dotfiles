# --- Zsh Cache & History Location ---
# These MUST be defined here so Zsh knows where to look at the very start.
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export HISTFILE="${ZSH_CACHE_DIR}/.zsh_history"

# --- Create Zsh Directories (if they don't exist) ---
# The variables are defined in .zshenv, but the directories are created here, once per login.
mkdir -p "$ZSH_CACHE_DIR"
mkdir -p "${ZSH_CACHE_DIR}/zsh_sessions" # The ZSH_SESSIONS_DIR var is also safe to move to .zshenv
