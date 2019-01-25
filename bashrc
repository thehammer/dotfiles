export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export EDITOR='emacs'

alias ll='ls -la'

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1='\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;32m\]$(parse_git_branch)\[\033[00m\]\$ '
