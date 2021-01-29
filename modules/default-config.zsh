# default prompt settings
zstyle ":prompt:naive:left"  items timer exit path user git prompt
zstyle ":prompt:naive:right" items clock
zstyle ":prompt:naive:right" enabled 1

zstyle ":prompt:naive:item:user"  show-host   0
zstyle ":prompt:naive:item:timer" show-larger 1
zstyle ":prompt:naive:item:git"   async       1

zstyle ":prompt:naive:*:clock"   content "%*"
zstyle ":prompt:naive:*:path"    content "%40<..<%~%<<"
zstyle ":prompt:naive:*:prompt"  content "%(!.#.$)"
zstyle ":prompt:naive:*:exit"    content "%(?..(%?%))" #TODO empty when no exit code
zstyle ":prompt:naive:*:newline" content $'\n'

zstyle ":prompt:naive:*:*"     pre  ""
zstyle ":prompt:naive:*:*"     post ""
zstyle ":prompt:naive:*:user"  pre  "%B%F{green}"
zstyle ":prompt:naive:*:user"  post "%f%b"
zstyle ":prompt:naive:*:timer" pre  "%F{yellow}"
zstyle ":prompt:naive:*:timer" post "%f"
zstyle ":prompt:naive:*:clock" pre  "%F{blue}"
zstyle ":prompt:naive:*:clock" post "%f"
zstyle ":prompt:naive:*:exit"  pre  "%F{red}"
zstyle ":prompt:naive:*:exit"  post "%f"
zstyle ":prompt:naive:*:path"  pre  "%B"
zstyle ":prompt:naive:*:path"  post "%b"

# git status order
zstyle ":prompt:naive:git" order \
  head \
  sep behind ahead \
  sep staged unstaged stash conflicts untracked clean \
  sep action
zstyle ":prompt:naive:git:pattern" prefix    "%F{250}[%f"
zstyle ":prompt:naive:git:pattern" head      "%F{120}?=%f"
zstyle ":prompt:naive:git:pattern" behind    "%F{216}??%{↓%G%}%f"
zstyle ":prompt:naive:git:pattern" ahead     "%F{216}??%{↑%G%}%f"
zstyle ":prompt:naive:git:pattern" sep       "%F{250}|%f"
zstyle ":prompt:naive:git:pattern" staged    "%F{117}??%{●%G%}%f"
zstyle ":prompt:naive:git:pattern" unstaged  "%F{226}??%{♦%G%}%f"
zstyle ":prompt:naive:git:pattern" conflicts "%F{9}??%{≠%G%}%f"
zstyle ":prompt:naive:git:pattern" untracked "%F{214}??%{…%G%}%f"
zstyle ":prompt:naive:git:pattern" clean     "%F{10}?:%B%{✓%G%}%b%f"
zstyle ":prompt:naive:git:pattern" suffix    "%F{250}]%f"
zstyle ":prompt:naive:git:pattern" action    "%F{yellow}??%f"

zstyle ":prompt:naive:git:fetch" pattern "pull|fetch"
zstyle ":prompt:naive:git:fetch" enabled 0
zstyle ":prompt:naive:git:stash" enabled 1
zstyle ":prompt:naive:git:dirty" untracked-as-dirty 1
