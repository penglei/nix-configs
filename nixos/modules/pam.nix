{ pkgs, username, ... }:
let
  gnupg-socketdir =
    "${pkgs.create-ssh-session-gnupg-socketdir}/bin/gnupg-socketdir";
  pamNamespace = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
    session optional pam_exec.so type=open_session ${gnupg-socketdir} ${username}
    session required pam_namespace.so ignore_instance_parent_mode
  '');
in {
  security.pam.services = {
    login.text = pamNamespace;
    sshd.text = pamNamespace;
  };

  systemd.tmpfiles.rules = [ "d /polymt 000 root root -" ];

  environment.etc = {
    "security/namespace.conf".text = ''
      /tmp    /polymt/tmp-    tmpdir    root
      /run/user/${username}/gnupg    /run/user/${username}/session-mounts/gnupg.inst-    tmpdir:create=0700    ~${username}
    '';
  };
}

