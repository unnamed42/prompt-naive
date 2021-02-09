zmodload zsh/zle
zmodload zsh/zutil

autoload -Uz colors && colors

source $PROMPT_NAIVE_ROOT/async.zsh
source $PROMPT_NAIVE_ROOT/modules/utils.zsh
source $PROMPT_NAIVE_ROOT/modules/section.zsh
source $PROMPT_NAIVE_ROOT/modules/git.zsh
source $PROMPT_NAIVE_ROOT/modules/default-config.zsh

prompt-naive-render-item() {
  local target="$1" lr

  [[ $target == PS1 ]] && lr=left || lr=right
  zstyle -a ":prompt:naive:$lr" items items
  local -a prompts
  for item in "${items[@]}"; do
    zstyle -s ":prompt:naive:$lr:$item" pre pre
    zstyle -s ":prompt:naive:$lr:$item" post post
    zstyle -s ":prompt:naive:$lr:$item" content content
    local fn="prompt-naive-section-$item"
    local prompt_part=""
    if typeset -f $fn > /dev/null; then
      prompt_part=$($fn)
    elif [[ -n $content ]]; then
      prompt_part=$content
    else
      echo "prompt: invalid $lr section $item configured"
      continue
    fi
    [[ -n "${prompt_part// }" ]] && prompts+=("${pre}$prompt_part${post}")
  done
  local render_result=${(j. .)prompts}
  [[ $lr == "left" ]] && render_result+=" "
  typeset -g "$target=$render_result"
}

prompt-naive-render() {
  prompt-naive-render-item PS1
  if zstyle -T ":prompt:naive:right" enabled; then
    prompt-naive-render-item RPS1
  fi
}

prompt-naive-reset() {
  [[ $CONTEXT == cont ]] && return
  zle && zle .reset-prompt
}

prompt-naive-preexec() {
  # the timer value will be lost on prompt reset
  prompt_naive_timer=$SECONDS
  async_flush_jobs "prompt-naive"
}

prompt-naive-precmd() {
  prompt_naive_last_exit=$?

  prompt-naive-save-timer
  unset prompt_naive_timer

  prompt-naive-async-start-git
  prompt-naive-render
}

prompt-naive-init() {
  autoload -U add-zsh-hook
  async_init
  add-zsh-hook preexec prompt-naive-preexec
  add-zsh-hook precmd  prompt-naive-precmd
  zle -N prompt-naive-reset
}

prompt-naive-init
