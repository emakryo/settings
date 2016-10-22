#!/bin/bash
# initial settings load script

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
echo $SCRIPT_DIR

# load bashrc in settings
echo "source $SCRIPT_DIR/bashrc" >> $HOME/.bashrc

# load emacs init.el
[ ! -d $HOME/.emacs.d ] && mkdir $HOME/.emacs.d
ln -s $SCRIPT_DIR/init.el $HOME/.emacs.d/init.el

# load vim settings
ln -s $SCRIPT_DIR/.vimrc $HOME
ln -s $SCRIPT_DIR/.vim $HOME

# load byobu settings
[ -f $HOME/.byobu/.tmux.conf ] && mv $HOME/.byobu/.tmux.conf $HOME/.byobu/.tmux.conf.bak
[ -d $HOME/.byobu ] && ln -s $SCRIPT_DIR/.tmux.conf $HOME/.byobu/
