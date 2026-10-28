ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
HISTFILE="$ZSH_CACHE_DIR/.zsh_history"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history inc_append_history_time hist_fcntl_lock hist_verify \
  hist_ignore_all_dups hist_expire_dups_first hist_find_no_dups hist_save_no_dups \
  hist_ignore_space hist_reduce_blanks no_beep auto_cd auto_pushd pushd_ignore_dups pushd_silent
