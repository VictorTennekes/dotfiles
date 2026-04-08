ctx() {
  # Copy file contents to clipboard with filename headers, ready for LLM context.
  # Usage: ctx file1.py file2.js  OR  ctx src/**/*.py
  if [[ $# -eq 0 ]]; then
    echo "Usage: ctx <file> [file...]" >&2
    return 1
  fi

  local output=""
  for f in "$@"; do
    if [[ -f "$f" ]]; then
      output+="# $f"$'\n'
      output+='```'$'\n'
      output+="$(cat "$f")"$'\n'
      output+='```'$'\n\n'
    else
      echo "Skipping '$f' (not a file)" >&2
    fi
  done

  echo -n "$output" | pbcopy
  echo "Copied $(echo "$@" | wc -w | tr -d ' ') file(s) to clipboard."
}
