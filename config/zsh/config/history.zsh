HISTSIZE=50000
SAVEHIST=50000

# Set Zsh options related to history.
setopt bang_hist               # Treat the '!' character specially during expansion.
setopt extended_history        # Write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first  # Expire a duplicate event first when trimming history.
setopt hist_find_no_dups       # Do not display a previously found event.
setopt hist_ignore_all_dups    # Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_dups        # Do not record an event that was just recorded again.
setopt hist_ignore_space       # Do not record an event starting with a space.
setopt hist_reduce_blanks      # Remove extra blanks from commands added to the history list.
setopt hist_save_no_dups       # Do not write a duplicate event to the history file.
setopt hist_verify             # Do not execute immediately upon history expansion.
setopt inc_append_history_time  # Write to history when command finishes (not on keystroke), avoids UI-blocking I/O.
setopt hist_fcntl_lock         # Use OS-level locking on the history file.
setopt NO_hist_beep            # Don't beep when accessing non-existent history.
setopt NO_beep                 # Disable all terminal beeps.

# Directory navigation
setopt auto_cd                 # Type a directory name to cd into it.
setopt auto_pushd              # Push directories onto the stack on cd.
setopt pushd_ignore_dups       # Don't push duplicate directories.
setopt pushd_silent            # Don't print the directory stack after pushd/popd.
