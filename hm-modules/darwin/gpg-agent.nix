{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.gpg-agent;

  gpgPkg = config.programs.gpg.package;
  homedir = config.programs.gpg.homedir;
  gpgconf = "${gpgPkg}/bin/gpgconf";

  gpgInitStr = ''
    GPG_TTY="$(tty)"
    export GPG_TTY
  '' + optionalString cfg.enableSshSupport
    "#${gpgPkg}/bin/gpg-connect-agent updatestartuptty /bye > /dev/null";
in {
  options = {
    gpg-agent = {
      enable = mkEnableOption "GnuPG private key agent";

      defaultCacheTtl = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Set the time a cache entry is valid to the given number of
          seconds.
        '';
      };

      defaultCacheTtlSsh = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Set the time a cache entry used for SSH keys is valid to the
          given number of seconds.
        '';
      };

      maxCacheTtl = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Set the maximum time a cache entry is valid to n seconds. After this
          time a cache entry will be expired even if it has been accessed
          recently or has been set using gpg-preset-passphrase. The default is
          2 hours (7200 seconds).
        '';
      };

      maxCacheTtlSsh = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Set the maximum time a cache entry used for SSH keys is valid to n
          seconds. After this time a cache entry will be expired even if it has
          been accessed recently or has been set using gpg-preset-passphrase.
          The default is 2 hours (7200 seconds).
        '';
      };

      enableSshSupport = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to use the GnuPG key agent for SSH keys.
        '';
      };

      sshKeys = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = ''
          Which GPG keys (by keygrip) to expose as SSH keys.
        '';
      };

      enableExtraSocket = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable extra socket of the GnuPG key agent (useful for GPG
          Agent forwarding).
        '';
      };

      verbose = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to produce verbose output.
        '';
      };

      grabKeyboardAndMouse = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Tell the pinentry to grab the keyboard and mouse. This
          option should in general be used to avoid X-sniffing
          attacks. When disabled, this option passes
          <option>no-grab</option> setting to gpg-agent.
        '';
      };

      enableScDaemon = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Make use of the scdaemon tool. This option has the effect of
          enabling the ability to do smartcard operations. When
          disabled, this option passes
          <option>disable-scdaemon</option> setting to gpg-agent.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = ''
          allow-emacs-pinentry
          allow-loopback-pinentry
        '';
        description = ''
          Extra configuration lines to append to the gpg-agent
          configuration file.
        '';
      };

      #pinentryFlavor = mkOption {
      #  type = types.nullOr (types.enum pkgs.pinentry.flavors);
      #  example = "gnome3";
      #  default = "null";
      #  description = ''
      #    Which pinentry interface to use. If not
      #    <literal>null</literal>, it sets
      #    <option>pinentry-program</option> in
      #    <filename>gpg-agent.conf</filename>.
      #  '';
      #};

      enableBashIntegration = mkEnableOption "Bash integration" // {
        default = true;
      };

      enableZshIntegration = mkEnableOption "Zsh integration" // {
        default = true;
      };

      enableFishIntegration = mkEnableOption "Fish integration" // {
        default = true;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.file."${homedir}/gpg-agent.conf".text = concatStringsSep "\n"
        (optional (cfg.enableSshSupport) "enable-ssh-support"
          ++ optional cfg.grabKeyboardAndMouse "grab"
          ++ optional (!cfg.enableScDaemon) "disable-scdaemon"
          ++ optional (cfg.defaultCacheTtl != null)
          "default-cache-ttl ${toString cfg.defaultCacheTtl}"
          ++ optional (cfg.defaultCacheTtlSsh != null)
          "default-cache-ttl-ssh ${toString cfg.defaultCacheTtlSsh}"
          ++ optional (cfg.maxCacheTtl != null)
          "max-cache-ttl ${toString cfg.maxCacheTtl}"
          ++ optional (cfg.maxCacheTtlSsh != null)
          "max-cache-ttl-ssh ${toString cfg.maxCacheTtlSsh}"
          #++ optional (cfg.pinentryFlavor != null)
          #"pinentry-program ${pkgs.pinentry.${cfg.pinentryFlavor}}/bin/pinentry"
          ++ [ cfg.extraConfig ]);

      home.sessionVariablesExtra = optionalString cfg.enableSshSupport ''
        export SSH_AUTH_SOCK="$(${gpgconf} --list-dirs agent-ssh-socket)"
      '';

      programs.bash.initExtra = mkIf cfg.enableBashIntegration gpgInitStr;
      programs.zsh.initContent = mkIf cfg.enableZshIntegration gpgInitStr;
      programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
        set -gx GPG_TTY (tty)
      '';
    }

    (mkIf (cfg.sshKeys != null) {
      # Trailing newlines are important
      home.file."${homedir}/sshcontrol".text = concatMapStrings (s: ''
        ${s}
      '') cfg.sshKeys;
    })

    (mkIf (pkgs.stdenv.isDarwin) {
      launchd.agents.gpg-agent-startup = {
        enable = true;
        config = {
          RunAtLoad = true;
          ProgramArguments =
            [ "/bin/zsh" "-c" "${gpgconf} --launch gpg-agent" ];
          EnvironmentVariables = {
            "GNUPGHOME" = homedir;
            "SHELL" = "/bin/sh";
          };
          StandardErrorPath = "/tmp/gpg-agent-launch.err.log";
          StandardOutPath = "/tmp/gpg-agent-launch.out.log";
        };
      };
    })
  ]);
}

