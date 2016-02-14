#!/bin/bash
# initial settings load script

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
echo $SCRIPT_DIR
[ -f $HOME/.bashrc ] && mv $HOME/.bashrc $HOME/.bashrc_local;
ln -s $SCRIPT_DIR/.bashrc $HOME/.bashrc
[ ! -d $HOME/.emasc.d ] && mkdir $HOME/.emasc.d
ln -s $SCRIPT_DIR/init.el $HOME/.emasc.d/init.el
