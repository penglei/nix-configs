{ pkgs, config, lib, ... }:

let key = (import ../../config.nix).ssh.authorized_key;
in {
  # home.file.".ssh/authorized_keys".text = key;

  home.activation.SetupAuthorizedSSHKeys =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''

      mkdir -p $HOME/.ssh
      $DRY_RUN_CMD  echo -n "${key}" > $HOME/.ssh/authorized_keys

    '';

  home.file.".ssh/config".text = ''
    Host *
      ServerAliveInterval 120
      TCPKeepAlive no
      ForwardAgent yes
      StrictHostKeyChecking no

    Include config.d/*

  '';

  #需要注意远端的socket 文件是否存在，如果是一个已经存在的socket，需要先删掉
  #在gpg-agent转发场景中，S.gpg-agent.sock通常是由默认的gpg-agent创建的，
  #使用gpgconfig --kill gpg-agent停止，自动删除不需要的socket。
  home.file.".ssh/config.d/vms".text = ''
    Host utm-vm
      Hostname 192.168.65.5
      RemoteForward /run/user/1000/gnupg/S.gpg-agent ${config.home.homeDirectory}/.gnupg/S.gpg-agent.extra
      #RemoteForward /home/penglei.gnupg/S.gpg-agent ${config.home.homeDirectory}/.gnupg/S.gpg-agent.extra
  '';
}
