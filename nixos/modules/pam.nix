{ pkgs, username, ... }:
let
  prepare-session = "${pkgs.prepare-session}/bin/entrypoint";

  pamNamespace = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
    session optional pam_exec.so type=open_session ${prepare-session} open_session ${username}
    session required pam_namespace.so ignore_instance_parent_mode
  '');

in {
  security.pam.services = {
    # login.text = pamNamespace;
    sshd.text = pamNamespace;
  };

  # systemd.tmpfiles.rules = [
  #   #Create an inaccessible directory that can be used to store session instance isolated directories.
  #   "d /polymt 000 root root -"
  # ];

  #https://github.com/linux-pam/linux-pam/blob/bc856cd9b9b461e8e2a537f4d9db87d315f5fe7b/modules/pam_namespace/pam_namespace.c#L836
  environment.etc = {
    "security/namespace.conf".text = ''
      # #isolate tmp directory to isolate SSH_AUTH_SOCK? It's unfriendly for some session software like tmux.
      # /tmp    /polymt/tmp-    tmpdir    root

      # v1: $uid/gnupg -> $username/gnupg(isolated)
      /run/user/${username}/gnupg       /run/user/${username}/.polydir/gnupg.inst-    tmpdir:create=0700    ~${username}
      # # v2: $uid/gnupg -> $username/gnupg -> $username.session(isolated)
      # /run/user/${username}/.session     /run/user/${username}/.polydir/sess-          tmpdir:create=0700    ~${username}
    '';
  };
}

