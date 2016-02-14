#!/bin/bash
# initial settings load script

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
echo $SCRIPT_DIR
[ -f $HOME/.bashrc ] && cat $HOME/.bashrc >> $HOME/.bashrc_local && rm $HOME/.bashrc
ln -s $SCRIPT_DIR/.bashrc $HOME/.bashrc
[ ! -d $HOME/.emacs.d ] && mkdir $HOME/.emacs.d
ln -s $SCRIPT_DIR/init.el $HOME/.emacs.d/init.el
