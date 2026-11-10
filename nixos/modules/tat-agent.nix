{ config, pkgs, ... }:
let
  suffix =
    if pkgs.stdenv.hostPlatform.isAarch64 then "_aarch64"
    else if pkgs.stdenv.hostPlatform.isx86_32 then "32"
    else "";

  tatAgent = pkgs.stdenv.mkDerivation {
    pname = "tat-agent";
    version = "1.2.2";

    src = builtins.path {
      path = /usr/local/qcloud/tat_agent/tat_agent_linux_install.tar.gz;
      sha256 = "sha256-jr/K2bfgCQOtQZRyWy1cOVnQ0mOSgrFG4DNW4kISlno=";
    };
    sourceRoot = "tat_agent_linux_install_1.2.2";

    nativeBuildInputs = with pkgs; [ gnutar gzip coreutils ];
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 "tat_agent${suffix}" "$out/bin/tat_agent"
      install -Dm755 "utmpx${suffix}" "$out/bin/utmpx"
      runHook postInstall
    '';

    meta.mainProgram = "tat_agent";
  };
in
{
  environment.systemPackages = [ tatAgent ];

  systemd.tmpfiles.rules = [
    "d /usr/local/bin 0755 root root -"
  ];

  systemd.services."tat_agent" = {
    description = "Tencent Cloud TAT agent";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.system.path ];

    # 运行目录必须可写：config.dat、日志、utmpx 都放在这里。
    preStart = ''
      ${pkgs.coreutils}/bin/install -m755 ${tatAgent}/bin/tat_agent /var/lib/tat_agent/tat_agent
      ${pkgs.coreutils}/bin/install -m755 ${tatAgent}/bin/utmpx /var/lib/tat_agent/utmpx
    '';

    environment = {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };

    serviceConfig = {
      Type = "forking";
      PIDFile = "/run/tat_agent.pid";
      StateDirectory = "tat_agent";
      StateDirectoryMode = "0700";
      WorkingDirectory = "/var/lib/tat_agent";
      ExecStart = "/var/lib/tat_agent/tat_agent";
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 0.2";
      KillMode = "process";
      Restart = "always";
      RestartSec = "1s";
      OOMPolicy = "continue";
    };
  };
}
