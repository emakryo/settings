#!/bin/bash
# initial settings load script

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
echo $SCRIPT_DIR

git submodule init
git submodule update

# load bashrc in settings
echo ". $SCRIPT_DIR/bashrc" >> $HOME/.bashrc

# load emacs init.el
#[ ! -d $HOME/.emacs.d ] && mkdir $HOME/.emacs.d
#ln -s $SCRIPT_DIR/init.el $HOME/.emacs.d/init.el

# load vim settings
ln -s $SCRIPT_DIR/.vimrc $HOME
ln -s $SCRIPT_DIR/.vim $HOME
vim -c "PlugInstall" -c "qall"

# load byobu settings
# [ -f $HOME/.byobu/.tmux.conf ] && mv $HOME/.byobu/.tmux.conf $HOME/.byobu/.tmux.conf.old
# [ -d $HOME/.byobu ] && ln -s $SCRIPT_DIR/byobu.tmux.conf $HOME/.byobu/.tmux.conf

# load tmux settings
[ -f $HOME/.tmux.conf ] && mv $HOME/.tmux.conf $HOME/.tmux.conf.old
ln -s $SCRIPT_DIR/.tmux.conf $HOME

# load git settings
[ -f $HOME/.gitconfig ] && mv $HOME/.gitconfig $HOME/.gitconfig.old
[ -f $HOME/.gitignore ] && mv $HOME/.gitignore $HOME/.gitignore.old
ln -s $SCRIPT_DIR/.gitconfig $HOME
ln -s $SCRIPT_DIR/.gitignore_global $HOME/.gitignore

# jupyter settings
# mkdir -p $HOME/.jupyter
# ln -s $SCRIPT_DIR/jupyter_nbconvert_config.py $HOME/.jupyter

# load mise settings
mkdir -p $HOME/.config
ln -s $SCRIPT_DIR/mise $HOME/.config/mise

# load zshrc
ln -s $SCRIPT_DIR/.zshrc $HOME

# load claude code settings
mkdir -p $HOME/.claude
[ -f $HOME/.claude/CLAUDE.md ] && mv $HOME/.claude/CLAUDE.md $HOME/.claude/CLAUDE.md.old
[ -f $HOME/.claude/settings.json ] && mv $HOME/.claude/settings.json $HOME/.claude/settings.json.old
[ -d $HOME/.claude/skills ] && mv $HOME/.claude/skills $HOME/.claude/skills.old
ln -s $SCRIPT_DIR/claude/CLAUDE.md $HOME/.claude/CLAUDE.md
ln -s $SCRIPT_DIR/claude/settings.json $HOME/.claude/settings.json
ln -s $SCRIPT_DIR/claude/skills $HOME/.claude/skills
