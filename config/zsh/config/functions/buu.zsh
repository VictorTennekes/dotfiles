buu() {
  # Colors
  GREEN="\033[0;32m"
  YELLOW="\033[1;33m"
  RESET="\033[0m"

  # Help menu
  if [[ "$1" == "help" || "$1" == "--help" ]]; then
    echo -e "${GREEN}Usage:${RESET} buu [option]"
    echo -e "Options:"
    echo -e "  ${YELLOW}greedy${RESET}    Upgrade with --greedy"
    echo -e "  ${YELLOW}dry-run${RESET}   Show what greedy upgrade would do"
    echo -e "  ${YELLOW}check${RESET}     Run brew doctor"
    echo -e "  ${YELLOW}help${RESET}      Show this help"
    return 0
  fi

  if [[ "$1" == "check" ]]; then
    echo -e "${GREEN}Running brew doctor...${RESET}"
    brew doctor
    return 0
  fi

  brew update

  # Determine upgrade command
  UPGRADE_CMD="brew upgrade"
  [[ "$1" == "greedy" ]] && UPGRADE_CMD="brew upgrade --greedy"

  # Check if anything to upgrade
  UPGRADABLE=$(brew outdated)
  if [[ -z "$UPGRADABLE" ]]; then
    return 0
  fi

  if [[ "$1" == "dry-run" ]]; then
    brew upgrade --greedy --dry-run
    return 0
  fi

  eval $UPGRADE_CMD

  brew cleanup

  # Regenerate zsh plugin static file if antidote was upgraded
  if command -v antidote &>/dev/null; then
    echo -e "${YELLOW}Regenerating zsh plugins...${RESET}"
    antidote bundle < ${ZDOTDIR}/zsh_plugins.txt > ${ZDOTDIR}/zsh_plugins.zsh
  fi

  echo -e "${GREEN}Done! ✅${RESET}"
}
