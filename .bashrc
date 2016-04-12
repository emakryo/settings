if [ -f ~/.bashrc_local ]
then
    . ~/.bashrc_local
fi

case $OSTYPE in
    *linux*  ) alias ls="ls --color=auto" ;;
    *cygwin*   ) alias ls="ls --show-control-chars --color=auto" ;;
    *darwin* ) alias ls="ls -G" ;;
esac

alias ll="ls -l"
alias la="ls -a"
alias emacs="emacs -nw"

export PS1="\A[\h@\u:\w]$ "
