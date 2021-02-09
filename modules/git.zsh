prompt-naive-async-start-git() {
  prompt-naive-async-setup-git
  async_worker_eval "prompt-naive" builtin cd -q $PWD
  typeset -gA prompt_naive_git_info
  if [[ $PWD != ${prompt_naive_git_info[pwd]}* ]]; then
    async_flush_jobs "prompt-naive"
    prompt_naive_git_info[top]=
  fi
  async_job "prompt-naive" prompt-naive-git-status
}

prompt-naive-async-setup-git() {
  typeset -g prompt_naive_async_git_loaded
  [[ -n $prompt_naive_async_git_loaded ]] && return
  async_start_worker       "prompt-naive" -u
  async_register_callback  "prompt-naive" prompt-naive-async-git-callback
  async_worker_eval        "prompt-naive" prompt-naive-async-renice
  prompt_naive_async_git_loaded=1
}

# lower the priority of background process, should be called by async_worker_eval
prompt-naive-async-renice() {
  if command -v renice > /dev/null; then
    command renice +15 -p $$
  fi
  if command -v ionice > /dev/null; then
    command ionice -c 3 -p $$
  fi
}

prompt-naive-async-git-callback() {
  local job=$1 code=$2 output=$3 pending=$6
  case $job in
    \[async]) ;;
    \[async/eval]) ;;
    prompt-naive-git-status)
      local -A info=("${(Q@)${(z)output}}")
      # directory changed before async task finishes, discard
      [[ $info[pwd] != $PWD ]] && return
      # update git info
      prompt_naive_git_info=("${(@fkv)info}")
      prompt-naive-render
      prompt-naive-reset
      ;;
  esac
}

prompt-naive-git-status() {
  local -A git_info=([clean]=0)
  local git_status="$(command git status -b -z --porcelain=v2 --ignore-submodules)"
  if [[ $? -ne 0 ]]; then
    git_info=(invalid 1)
    echo -nE ${(kvq)git_info}
    return
  fi
  # setting vcs_info inside async task
  zstyle ":vcs_info:*"     enable        git
  zstyle ":vcs_info:*"     use-simple    true
  zstyle ":vcs_info:*"     max-exports   2
  zstyle ":vcs_info:git:*" formats       "%R" "%a"
  zstyle ":vcs_info:git:*" actionformats "%R" "%a"
  autoload -U vcs_info && vcs_info
  git_info+=([pwd]=$PWD [top]=$vcs_info_msg_0_ [action]=$vcs_info_msg_1_)
  for line in ${(0)git_status}; do
    local parts=(${(ps: :)line})
    # porcelain-v2 branch info
    case $parts[2] in
      branch.oid)      git_info[hash]=$parts[3];;
      branch.head)     git_info[head]=$parts[3];;
      branch.upstream) git_info[upstream]=$parts[3];;
      branch.ab)       git_info[ahead]=${parts[3]#+}; git_info[behind]=${parts[4]#-};;
    esac
    # tracking file status
    case $parts[1] in
      "?") (( git_info[untracked]++ ));;
      u)   (( git_info[unmerged]++ ));;
      1|2)
        if [[ ${parts[2]:0:1} != "." ]]; then (( git_info[staged]++ )); fi
        if [[ ${parts[2]:1:1} != "." ]]; then (( git_info[unstaged]++ )); fi
        ;;
    esac
  done
  # git stash count
  if zstyle -t ":prompt:naive:git:stash" enabled; then
    local stash=$(command git rev-list --walk-reflogs --count refs/stash 2> /dev/null)
    [[ -n $stash ]] && git_info[stash]=$stash
  fi
  # use commit hash if no valid branch name or tag name exist
  if [[ $git_info[head] == "(detached)" ]]; then
    local git_tag=$(command git tag --points-at=HEAD --sort=committerdate | head -1)
    if [[ -n $git_tag ]]; then
      git_info[head]=$git_tag
    else
      git_info[head]=${git_info[hash]:0:7}
    fi
  fi
  # git clean indicator
  if (( !git_info[untracked] && \
        !git_info[unmerged] && \
        !git_info[staged] && \
        !git_info[unstaged] \
    )); then git_info[clean]=1; fi
  echo -nE ${(kvq)git_info}
}
