if [ -f .bashrc_local ]
then
    source .bashrc_local
fi

case $OSTYPE in
    *linux*  ) alias ls="ls --color=auto" ;;
    *cygwin*   ) alias ls="ls --show-control-chars --color=auto" ;;
    *darwin* ) alias ls="ls -G" ;;
esac

alias ll="ls -l"
alias la="ls -a"

export PS1="\A[\h@\u:\w]$ "
