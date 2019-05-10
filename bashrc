case $OSTYPE in
    *linux*  ) alias ls="ls --color=auto" ;;
    *cygwin*   ) alias ls="ls --show-control-chars --color=auto" ;;
    *darwin* ) alias ls="ls -FG" ;;
esac

alias l="ls"
alias ll="ls -l"
alias la="ls -a"
alias emacs="emacs -nw"
alias g++="g++ -std=c++11"

if [ `echo $TERM | grep 256` ]; then
	color256 () { echo -n "\[\e[38;5;$1m\]$2\[\e[0m\]"; }
	raw_color256 () { echo -ne "\033[38;5;$1m$2\033[0m"; } # this causes incorrect line wrapping
else
	color256 () { echo -n $2; }
	raw_color256 () { echo -n $2; }
fi

__exit_color() {
	if [ $1 != 0 ]; then
		echo 9
	else
		echo 10
	fi
	exit $1
}

__ps1_base="$(color256 '$(__exit_color $?)' \$?) $(color256 81 \\A) $(color256 161 \\u)@$(color256 208 \\h): $(color256 118 '$(basename \w)')$(color256 135 '$(__git_ps1)')"

__new_line_if_narrow() {
	if [ `tput cols` -le 80 ]; then
		echo '\n'
	fi
}

PROMPT_COMMAND='PS1=$CONDA_PROMPT_MODIFIER$__ps1_base$(__new_line_if_narrow)"$ "'

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
