#!/bin/bash
# Usage: ./execbg.sh [command]
# you can include input redirect but must not include output redirect

file=`echo $* | sed -e "s/ /_/g" -e "s/\//_/g"`_`date +"%F_%T"`
echo $file
if [ `echo "$*" | grep ">"` ]
then
    echo "No output redirection"
    exit 1
fi

if [ `echo "$*" | grep "<"` ]
then
    nohup $@ > $file.log 2> $file.err &
else
    nohup $@ > $file.log 2> $file.err < /dev/null &
fi
