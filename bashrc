case $OSTYPE in
    *linux*  ) alias ls="ls --color=auto" ;;
    *cygwin*   ) alias ls="ls --show-control-chars --color=auto" ;;
    *darwin* ) alias ls="ls -FG" ;;
esac

alias l="ls"
alias ll="ls -l"
alias la="ls -a"
alias emacs="emacs -nw"

mkcd () {
	if [ ! -n "$1" ]; then
		echo Usage: mkcd directory
		return 1
	elif [ -d "$1" ]; then
		echo "$1": Already exists
		cd "$1"
	elif [ -e "$1" ]; then
		echo "$1": Not a directory
		return 1
	else
		mkdir -p "$1" && cd "$1"
	fi
}


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

countdown(){
	date1=$((`date +%s` + $1));
	while [ "$date1" -ge `date +%s` ]; do 
	## Is this more than 24h away?
	#days=$(($(($(( $date1 - $(date +%s))) * 1 ))/86400))
	echo -ne "  $(date -j -v+15H -f '%s' $(($date1 - `date +%s`)) +%H:%M:%S)\r";
	sleep 0.1
	done
}

stopwatch(){
	date1=`date +%s`; 
	while true; do 
	days=$(( $(($(date +%s) - date1)) / 86400 ))
	echo -ne "  $(date -j -v+15H -f '%s' $((`date +%s` - $date1)) +%H:%M:%S)\r";
	sleep 0.1
	done
}
