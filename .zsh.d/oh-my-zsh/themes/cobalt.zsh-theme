# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$fg%} "
    # echo $(pwd | sed -e "s,^$HOME,~," | sed "s@\(.\)[^/]*/@\1/@g")
    # echo $(pwd | sed -e "s,^$HOME,~,")
  fi
  CURRENT_BG='NONE'
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)✝"
  fi
}

is_bisecting() {
  # return 1;
  local repo_path
  [[ -n $1 ]] && repo_path=$1
  if [[ -e "${repo_path}/BISECT_LOG" ]]; then
    return 0
  else
    return 1
  fi
}

is_merging() {
  local repo_path
  [[ -n $1 ]] && repo_path=$1
  if [[ -e "${repo_path}/MERGE_HEAD" ]]; then
    return 0
  else
    return 1
  fi
}

is_rebasing() {
  local repo_path
  [[ -n $1 ]] && repo_path=$1
  if [[ -e "${repo_path}/rebase"
        || -e "${repo_path}/rebase-apply"
        || -e "${repo_path}/rebase-merge"
        || -e "${repo_path}/../.dotest"
      ]]; then
    return 0
  else
    return 1
  fi
}

# Add bisecting, merge and rebase mode indicators
prompt_git_modes() {
  local mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  mode=()
  is_bisecting $repo_path && mode+="%{%F{green}%}[BISECT]"
  is_merging $repo_path && mode+="%{%F{red}%}[MERGE]"
  is_rebasing $repo_path && mode+="%{%F{red}%}[REBASE]"
  [[ -n "$mode" ]] && prompt_segment black default "$mode"
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY=" ✗"
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment black yellow
    else
      prompt_segment black green
    fi
    echo -n "${ref/refs\/heads\// }$dirty"

    prompt_git_modes
  fi
}

# Dir: current working directory
prompt_dir() {
  git_root=$PWD
  while [[ $git_root != / && ! -e $git_root/.git ]]; do
    git_root=$git_root:h
  done
  if [[ $git_root = / ]]; then
    unset git_root
    prompt_short_dir=%~
  else
    parent=${git_root%\/*}
    prompt_short_dir=${PWD#$parent/}
  fi

  prompt_segment black blue $prompt_short_dir
  # echo $(pwd | sed -e "s,^$HOME,~," | sed "s@\(.\)[^/]*/@\1/@g")
}


# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  # prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt)'