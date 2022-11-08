{ pkgs, config, ... }:

{
  programs.gpg = {
    enable = true;
    settings = {
      # https://gist.github.com/graffen/37eaa2332ee7e584bfda
      "no-emit-version" = true;
      "no-comments" = true;
      "use-agent" = true;
      "with-fingerprint" = true;
      "with-subkey-fingerprint" = true;
      "with-keygrip" = true;
      #"show-unusable-subkeys" = true;
      "keyid-format" = "long";

      "list-options" = "show-uid-validity";

      # list of personal digest preferences. When multiple digests are supported by
      # all recipients, choose the strongest one
      "personal-cipher-preferences" = "AES256 TWOFISH AES192 AES";

      # list of personal digest preferences. When multiple ciphers are supported by
      # all recipients, choose the strongest one
      "personal-digest-preferences" = "SHA512 SHA384 SHA256 SHA224";

      # message digest algorithm used when signing a key
      "cert-digest-algo" = "SHA512";

      # This preference list is used for new keys and becomes the default for "setpref" in the edit menu
      "default-preference-list" =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
    };
  };

  gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableScDaemon = true;
    sshKeys = [
      # List of allowed ssh keys.  Only keys present in this file are used
      # in the SSH protocol.  The ssh-add tool may add new entries to this
      # file to enable them; you may also add them manually.  Comment
      # lines, like this one, as well as empty lines are ignored.  Lines do
      # have a certain length limit but this is not serious limitation as
      # the format of the entries is fixed and checked by gpg-agent. A
      # non-comment line starts with optional white spaces, followed by the
      # keygrip of the key given as 40 hex digits, optionally followed by a
      # caching TTL in seconds, and another optional field for arbitrary
      # flags.   Prepend the keygrip with an '!' mark to disable it.
      "3B399574276E0CB8C31E6131C2E9AA60750AFD7A" # legacy ssh
      "DA4F387CA3DA3CFED81DA37792471D7D8704C8D6" # gpg auth key
    ];
  };
}
