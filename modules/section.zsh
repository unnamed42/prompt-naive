prompt-naive-section-timer() {
  echo $prompt_naive_exec_time
}

prompt-naive-section-venv() {
  local result
  if [[ ${VIRTUAL_ENV:t} == ".venv" ]]; then
    result="${VIRTUAL_ENV:h:t}"
  elif [[ $PIPENV_ACTIVE ]]; then
    # remove hash
    result=${${VIRTUAL_ENV%-*}:t}
  elif [[ $POETRY_ACTIVE ]]; then
    # remove hash and version number
    result=${${${VIRTUAL_ENV%-*}%-*}:t}
  else
    result=${${VIRTUAL_ENV:t}:-${CONDA_DEFAULT_ENV//[$'\t\r\n']/}}
  fi
  echo $result
}

prompt-naive-section-user() {
  local __user
  if [[ "$DEFAULT_USER" == "$USER" ]]; then
    __user=""
  elif [[ -n "$SUDO_USER" && "$SUDO_USER" != "$__user" ]]; then
    __user="$USER($SUDO_USER)"
  else
    __user="$USER"
  fi
  if zstyle -t ":prompt:naive:item:user" show-host; then
    __user+="@%M"
  fi
  echo "$__user"
}

prompt-naive-section-git() {
  [[ -n $prompt_naive_git_info[invalid] || -z $prompt_naive_git_info[top] ]] && return
  zstyle -a ":prompt:naive:git" order git_parts
  zstyle -s ":prompt:naive:git:pattern" prefix prefix
  zstyle -s ":prompt:naive:git:pattern" suffix suffix
  zstyle -s ":prompt:naive:git:pattern" space  space
  zstyle -s ":prompt:naive:git:pattern" sep    separator
  local expanded_section=""
  local -a git_sections=()
  for name in ${git_parts[@]}; do
    local value=${prompt_naive_git_info[$name]} expanded=""
    if [[ $name == sep ]]; then
      [[ -n $expanded_section ]] && git_sections+=("$expanded_section")
      expanded_section=""
      continue
    fi
    zstyle -s ":prompt:naive:git:pattern" $name pattern
    case $pattern in
      *"??"*) [[ ${value:-0} -ne 0 ]] && expanded=${pattern//\?\?/$value} ;;
      *"?:"*)   (( value ))           && expanded=${pattern//\?:/}        ;;
      *"?="*)                            expanded=${pattern//\?\=/$value} ;;
      *)                                 expanded=$pattern                ;;
    esac
    expanded_section+=$expanded
  done
  [[ -n $expanded_section ]] && git_sections+=("$expanded_section")
  [[ ${#git_sections[@]} -ne 0 ]] && () {
    joined_section=$(prompt-naive-join $separator ${git_sections[*]})
    echo "${prefix}$joined_section${suffix}"
  }
}
