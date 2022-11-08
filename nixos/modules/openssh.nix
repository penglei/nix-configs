{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";

      # Specifies whether to remove an existing Unix-domain socket file for local or
      # remote port forwarding before creating a new one.  If the socket file already
      # exists and StreamLocalBindUnlink is not enabled, ssh will be unable to forward
      # the port to the Unix-domain socket file.  This option is only used for port for‐
      # warding to a Unix-domain socket file.
      StreamLocalBindUnlink = "yes";

    };
  };
}

