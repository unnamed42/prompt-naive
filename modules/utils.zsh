prompt-naive-save-timer() {
  local elapsed_thres result
  typeset -g prompt_naive_exec_time=
  zstyle -s ":prompt:naive:item:timer" show-larger elapsed_thres
  local elapsed=$(( $SECONDS - ${prompt_naive_timer:-$SECONDS} ))
  if (( $elapsed >= $elapsed_thres )); then
    local seconds=$(( $elapsed % 60 ))
    local minutes=$(( $elapsed / 60 % 60 ))
    local hours=$(( $elapsed / 3600 % 24 ))
    (( $hours > 0 )) && result+="${hours}h"
    (( $minutes > 0 )) && result+="${minutes}m"
    result+="${seconds}s"
    typeset -g prompt_naive_exec_time=$result
  fi
}

prompt-naive-join() {
  local sep=$1 result=$2; shift 2
  for arg in "$@"; do result+="$sep$arg"; done
  echo $result
}
