#!/usr/bin/env bash

username="$1"

#export PATH=/usr/bin:/usr/sbin:$PATH

if [ "$PAM_USER" = "$username" ]; then

  session_uid=$(id -u "$PAM_USER")
  mkdir -p /run/user/"$PAM_USER"/

  gnupgsockdir=/run/user/$session_uid/gnupg
  if [ ! -L "$gnupgsockdir" ]; then
    rm -rf "$gnupgsockdir"

    #we don't create target gnupg directory directly, which would be create by pam_namespace module
    exec runuser -u "$PAM_USER" -- ln -s /run/user/"$PAM_USER"/gnupg /run/user/"$session_uid"/gnupg
  fi
fi
