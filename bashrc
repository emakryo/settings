case $OSTYPE in
    *linux*  ) alias ls="ls --color=auto" ;;
    *cygwin*   ) alias ls="ls --show-control-chars --color=auto" ;;
    *darwin* ) alias ls="ls -G" ;;
esac

alias ll="ls -l"
alias la="ls -a"
alias emacs="emacs -nw"

if [ `echo $TERM | grep 256` ]; then
	color256 () { echo -n "\[\e[38;5;$1m\]$2\[\e[0m\]"; }
	export PS1="$(color256 81 \\A) $(color256 161 \\u)@$(color256 208 \\h): $(color256 118 '$(basename \w)')$ "
fi

export LESS='-R'

if [[ -x `which colordiff` ]]
then
	alias diff='colordiff -u'
else
	alias diff='diff -u'
fi
