clip() {
  # If arguments are provided, treat the first one as a file to copy.
  if [[ $# -gt 0 ]]; then
    if [[ -f "$1" ]]; then
      pbcopy < "$1" && echo "Copied contents of '$1' to clipboard."
    else
      echo "Error: '$1' is not a valid file." >&2
      return 1
    fi
  # If NO arguments are provided, read from standard input.
  else
    pbcopy && echo "Copied from stdin to clipboard."
  fi
}
