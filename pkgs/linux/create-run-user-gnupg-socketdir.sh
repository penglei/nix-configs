#!/usr/bin/env bash

username="$1"

#export PATH=/usr/bin:/usr/sbin:$PATH

if [ "$PAM_USER" = "$username" ]; then

  session_uid=$(id -u "$PAM_USER")
  mkdir -p /run/user/"$PAM_USER"/

  gnupg_sockdir=/run/user/$session_uid/gnupg
  if [ ! -L "$gnupg_sockdir" ]; then
    rm -rf "$gnupg_sockdir"

    #we don't create gnupg runtime source directory directly, which would be create by pam_namespace module
    exec runuser -u "$PAM_USER" -- ln -s /run/user/"$PAM_USER"/gnupg "$gnupg_sockdir"
  fi
fi
