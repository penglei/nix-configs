#!/usr/bin/env bash

###############how it works ? ############
#content=$(echo XXX | base64)
#echo -e -n "\e]52;c;$content\a"
##########################################

echo -e -n "\e]52;c;"
base64 -w0 </dev/stdin
echo -e -n "\a"
