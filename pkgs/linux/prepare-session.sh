#!/usr/bin/env bash

action="$1"
username="$2"

SESSION_DIR="/run/user/.session" #session isolated directory
function open_session() {

  SESSION_UID=$(id -u "$PAM_USER")
  mkdir -p /run/user/"$PAM_USER"/
  # #Change directory owner  is elegant, but it would cause pam_namespace
  # #do multiple mounts to fix permission (run 'mount' to see)!
  chown "$PAM_USER" "/run/user/$PAM_USER"

  #{gnupg socket
  user_gnupg_sockdir=/run/user/$PAM_USER/gnupg
  uid_gnupg_sockdir=/run/user/$SESSION_UID/gnupg

  if [ ! -L "$uid_gnupg_sockdir" ]; then
    rm -rf "$uid_gnupg_sockdir"
  fi
  if [ -L "$uid_gnupg_sockdir" ]; then
    rm "$uid_gnupg_sockdir"
  fi
  if [ ! -L "$user_gnupg_sockdir" ]; then
    rm -rf "$user_gnupg_sockdir"
  fi
  if [ -L "$user_gnupg_sockdir" ]; then
    rm "$user_gnupg_sockdir"
  fi

  #link to real path
  #gpg 命令无法配置socket路径，只能放在几个固定的地方，
  #如XDG_RUNTIME_DIR(/run/user/$SESSION_UID/gnupg/S.gpg-agent)
  runuser -u "$PAM_USER" -- ln -s "$user_gnupg_sockdir" "$uid_gnupg_sockdir"
  #for convennient, login user can specify directory named by username for forwarding.

  runuser -u "$PAM_USER" -- ln -s "$SESSION_DIR" "$user_gnupg_sockdir"
  #}

  # #SSH_AUTH_SOCK location is hard-coded in tmp, we have no idea how to isolate it.
  # #see: https://github.com/openssh/openssh-portable/blob/bef92346c4a808f33216e54d6f4948f9df2ad7c1/session.c#L191
  # sshagent_sockdir=/run/user/$PAM_USER/sshd
  # runuser -u "$PAM_USER" -- ln -s "$SESSION_DIR" "$sshagent_sockdir"

}

function close_session() {
  rm -rf "$SESSION_DIR"
}

if [ "$PAM_USER" = "$username" ]; then
  case "$action" in
  "open_session")
    open_session
    ;;
  "close_session")
    close_session
    ;;
  esac
fi
