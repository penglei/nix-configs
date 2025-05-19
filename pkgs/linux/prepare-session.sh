#!/usr/bin/env bash

action="$1"
username="$2"

if [ "$PAM_USER" = "$username" ]; then

  session_dir="/run/user/$PAM_USER/.session"

  if [ "$action" == "close_session" ]; then
    rm -rf "$session_dir"
    exit
  fi

  mkdir -p /run/user/"$PAM_USER"/
  chown "$PAM_USER" "/run/user/$PAM_USER"

  user_gnupg_sockdir=/run/user/$PAM_USER/gnupg
  if [ ! -L "$user_gnupg_sockdir" ]; then
    rm -rf "$user_gnupg_sockdir"
  fi
  if [ -L "$user_gnupg_sockdir" ]; then
    rm "$user_gnupg_sockdir"
  fi
  runuser -u "$PAM_USER" -- ln -s "$session_dir" "$user_gnupg_sockdir"

  SESSION_UID=$(id -u "$PAM_USER")
  uid_gnupg_sockdir=/run/user/$SESSION_UID/gnupg
  if [ ! -L "$uid_gnupg_sockdir" ]; then
    rm -rf "$uid_gnupg_sockdir"
  fi
  if [ -L "$uid_gnupg_sockdir" ]; then
    rm "$uid_gnupg_sockdir"
  fi
  runuser -u "$PAM_USER" -- ln -s "$user_gnupg_sockdir" "$uid_gnupg_sockdir"

  # #SSH_AUTH_SOCK location is hard-coded in tmp, we have no idea how to isolate it.
  # #see: https://github.com/openssh/openssh-portable/blob/bef92346c4a808f33216e54d6f4948f9df2ad7c1/session.c#L191
  # sshagent_sockdir=/run/user/$PAM_USER/sshd
  # if [ ! -L "$sshagent_sockdir" ]; then
  #   rm -rf "$sshagent_sockdir"
  # fi
  # if [ -L "$sshagent_sockdir" ]; then
  #   rm "$sshagent_sockdir"
  # fi
  # runuser -u "$PAM_USER" -- ln -s "$session_dir" "$sshagent_sockdir"

fi
