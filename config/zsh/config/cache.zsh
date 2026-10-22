# --- Zsh Cache & History Location ---
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export HISTFILE="${ZSH_CACHE_DIR}/.zsh_history"

# --- Create Zsh Cache Directory ---
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"
