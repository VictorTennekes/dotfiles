# --- Pyenv ---
# Set pyenv root and add its bin to the PATH if it exists.
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

# --- Application Paths ---
JETBRAINS_SCRIPTS="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
if [[ -d "$JETBRAINS_SCRIPTS" ]]; then
  export PATH="$PATH:$JETBRAINS_SCRIPTS"
fi
