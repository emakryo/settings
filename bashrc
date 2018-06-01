case $OSTYPE in
    *linux*  ) alias ls="ls --color=auto" ;;
    *cygwin*   ) alias ls="ls --show-control-chars --color=auto" ;;
    *darwin* ) alias ls="ls -FG" ;;
esac

alias l="ls"
alias ll="ls -l"
alias la="ls -a"
alias emacs="emacs -nw"

if [ `echo $TERM | grep 256` ]; then
	color256 () { echo -n "\[\e[38;5;$1m\]$2\[\e[0m\]"; }
	raw_color256 () { echo -ne "\e[38;5;$1m$2\e[0m"; }
else
	color256 () { echo -n $2; }
	raw_color256 () { echo -n $2; }
fi

__color_exit_status() {
	if [ $1 != 0 ]; then
		raw_color256 9 $1
	else
		raw_color256 10 $1
	fi
}

PS1="\$(__color_exit_status \$?) $(color256 81 \\A) $(color256 161 \\u)@$(color256 208 \\h): $(color256 118 '$(basename \w)')$(color256 135 '$(__git_ps1)')$ "

if [ $BASH_VERSINFO -ge 4 ]; then
	shopt -s autocd
fi

export LESS='-R'

if [[ -x `which colordiff` ]]
then
	alias diff='colordiff -u'
else
	alias diff='diff -u'
fi

shopt -s histappend
HISTSIZE=50000
