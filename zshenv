###############################
#         Environment         #
###############################

autoload -U compinit
compinit
autoload -U colors
colors

autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

setopt no_auto_menu
setopt prompt_subst
set -o emacs

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export EDITOR='emacs'
export VISUAL='emacs'

export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zhistory
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt EXTENDED_HISTORY

export ERL_AFLAGS="-kernel shell_history enabled"

export PATH=/usr/local/bin:$PATH

###############################
#       Command Prompt        #
###############################

function __promptline_host {
    local hostname=$(hostname)

    case "${hostname}" in
        Miyamoto.local) print "Miyamoto" ;;
        *)              print %m ;;
    esac
}

function __promptline_last_exit_code {
  [[ $last_exit_code -gt 0 ]] || return 1;

  printf "%s" "$last_exit_code"
}

function __promptline_vcs_branch {
  local branch
  local branch_symbol=" "

  # git
  if hash git 2>/dev/null; then
    if branch=$( { git symbolic-ref --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null ); then
      branch=${branch##*/}
      printf "%s" "${branch_symbol}${branch:-unknown}"
      return
    fi
  fi
  return 1
}

function __promptline_cwd {
  local dir_limit="3"
  local truncation="⋯"
  local first_char
  local part_count=0
  local formatted_cwd=""
  local dir_sep="  "
  local tilde="~"

  local cwd="${PWD/#$HOME/$tilde}"

  # get first char of the path, i.e. tilde or slash
  first_char=$cwd[1,1] || first_char=${cwd::1}

  # remove leading tilde
  cwd="${cwd#\~}"

  while [[ "$cwd" == */* && "$cwd" != "/" ]]; do
    # pop off last part of cwd
    local part="${cwd##*/}"
    cwd="${cwd%/*}"

    formatted_cwd="$dir_sep$part$formatted_cwd"
    part_count=$((part_count+1))

    [[ $part_count -eq $dir_limit ]] && first_char="$truncation" && break
  done

  printf "%s" "$first_char$formatted_cwd"
}

function __promptline_wrapper {
    # wrap the text in $1 with $2 and $3, only if $1 is not empty
    # $2 and $3 typically contain non-content-text, like color escape codes and separators

    [[ -n "$1" ]] || return 1
    printf "%s" "${2}${1}${3}"
}

function __promptline_left_prompt {
  local slice_prefix slice_empty_prefix slice_joiner slice_suffix is_prompt_empty=1

  # Section A
  slice_prefix="${a_bg}${sep}${a_fg}${a_bg}${space}"
  slice_suffix="$space${a_sep_fg}"
  slice_joiner="${a_fg}${a_bg}${alt_sep}${space}"
  slice_empty_prefix="${a_fg}${a_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  __promptline_wrapper "$(__promptline_host)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # Section B
  slice_prefix="${b_bg}${sep}${b_fg}${b_bg}${space}"
  slice_suffix="$space${b_sep_fg}"
  slice_joiner="${b_fg}${b_bg}${alt_sep}${space}"
  slice_empty_prefix="${b_fg}${b_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  __promptline_wrapper "$USER" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # Section C
  slice_prefix="${c_bg}${sep}${c_fg}${c_bg}${space}"
  slice_suffix="$space${c_sep_fg}"
  slice_joiner="${c_fg}${c_bg}${alt_sep}${space}"
  slice_empty_prefix="${c_fg}${c_bg}${space}"
  [ $is_prompt_empty -eq 1 ] && slice_prefix="$slice_empty_prefix"
  __promptline_wrapper "$(__promptline_cwd)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; is_prompt_empty=0; }

  # Close Sections
  printf "%s" "${reset_bg}${sep}$reset$space"
}

function __promptline_right_prompt {
  local slice_prefix slice_empty_prefix slice_joiner slice_suffix

  # Section Warn
  slice_prefix="${warn_sep_fg}${rsep}${warn_fg}${warn_bg}${space}"
  slice_suffix="$space${warn_sep_fg}"
  slice_joiner="${warn_fg}${warn_bg}${alt_rsep}${space}"
  slice_empty_prefix=""
  __promptline_wrapper "$(__promptline_last_exit_code)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; }

  # Section Y
  slice_prefix="${y_sep_fg}${rsep}${y_fg}${y_bg}${space}"
  slice_suffix="$space${y_sep_fg}"
  slice_joiner="${y_fg}${y_bg}${alt_rsep}${space}"
  slice_empty_prefix=""
  __promptline_wrapper "$(__promptline_vcs_branch)" "$slice_prefix" "$slice_suffix" && { slice_prefix="$slice_joiner"; }

  # Close Sections
  printf "%s" "$reset"
}

function __promptline {
  local last_exit_code="${PROMPTLINE_LAST_EXIT_CODE:-$?}"

  local esc=$'[' end_esc=m
  local noprint='%{' end_noprint='%}'
  local wrap="$noprint$esc" end_wrap="$end_esc$end_noprint"
  local space=" "
  local sep=""
  local rsep=""
  local alt_sep=""
  local alt_rsep=""
  local reset="${wrap}0${end_wrap}"
  local reset_bg="${wrap}49${end_wrap}"
  local a_fg="${wrap}38;5;255${end_wrap}"
  local a_bg="${wrap}48;5;31${end_wrap}"
  local a_sep_fg="${wrap}38;5;30${end_wrap}"
  local b_fg="${wrap}38;5;254${end_wrap}"
  local b_bg="${wrap}48;5;237${end_wrap}"
  local b_sep_fg="${wrap}38;5;237${end_wrap}"
  local c_fg="${wrap}38;5;254${end_wrap}"
  local c_bg="${wrap}48;5;234${end_wrap}"
  local c_sep_fg="${wrap}38;5;234${end_wrap}"
  local warn_fg="${wrap}38;5;232${end_wrap}"
  local warn_bg="${wrap}48;5;166${end_wrap}"
  local warn_sep_fg="${wrap}38;5;166${end_wrap}"
  local y_fg="${wrap}38;5;254${end_wrap}"
  local y_bg="${wrap}48;5;237${end_wrap}"
  local y_sep_fg="${wrap}38;5;237${end_wrap}"

  PROMPT="$(__promptline_left_prompt)"
  RPROMPT="$(__promptline_right_prompt)"
}

if [[ ! ${precmd_functions[(r)__promptline]} == __promptline ]]; then
    precmd_functions+=(__promptline)
fi

