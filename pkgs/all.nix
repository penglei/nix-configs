final: prev:
let pkgs = final;
in with pkgs; {
  # apple_sdk_extend.frameworks = let
  #   apple_sdk_maker = callPackage ./darwin/framework.nix {
  #     inherit buildPackages;
  #     inherit (darwin.apple_sdk) MacOSX-SDK;
  #   };
  # in { MediaRemote = apple_sdk_maker.privateFramework "MediaRemote" { }; };

  createscript = callPackage ./createscript.nix { };

  kubectl-kubectx = callPackage ./kubectl/kubectx.nix { };
  kubectl-kubecm = callPackage ./kubectl/kubecm.nix { };
  kubectl-nodeshell = callPackage ./kubectl/nodeshell.nix { };

  utm = (prev.utm.overrideAttrs
    (import ./darwin/utm.nix { inherit fetchurl makeWrapper; }).override);

  netnewswire = callPackage ./darwin/netnewswire.nix { };
  rectangle = callPackage ./darwin/rectangle.nix { };
  tart = callPackage ./darwin/tart.nix { };

  # droidsans_fonts = callPackage ./fonts/droidsans.nix { };
  # hack-nerd-font = callPackage ./fonts/hack.nix { }; Some symbols needed by neovim NvChad are missing.
  # apple-sfmono-font = callPackage ./fonts/sfmono.nix { };
  # apple-sfmono-nerd-font = callPackage ./fonts/sfmono-nerd.nix { };

  preview_open = callPackage ./darwin/preview.nix { };

  isabelle_app = callPackage ./darwin/isabelle.nix { };

  mynixcleaner = callPackage ./nix-cleaner.nix { };

  # nix-direnv = callPackage ./nix-direnv { };

  # mongosh = callPackage ./mongosh { };

  # koodo-reader = callPackage ./darwin/koodo-reader.nix { };

  # alacritty-custom = callPackage ./alacritty.nix {
  #   inherit (darwin.apple_sdk.frameworks)
  #     AppKit CoreGraphics CoreServices CoreText Foundation OpenGL;
  # };

  #bitwarden-desktop = callPackage ./darwin/bitwarden-desktop.nix { };
  #spacelauncher = callPackage ./darwin/spacelauncher.nix { };

  # sketchybar = callPackage ./darwin/sketchybar.nix {
  #   inherit (darwin.apple_sdk.frameworks)
  #     Carbon Cocoa CoreWLAN DisplayServices SkyLight;
  #   inherit (apple_sdk_extend.frameworks) MediaRemote;
  # };

  presentation = callPackage ./darwin/presentation.nix { };
  adobe-reader = callPackage ./darwin/adobe-reader.nix { };
  keycastr = callPackage ./darwin/keycastr.nix { };
  keycodes = callPackage ./darwin/keycodes.nix { };
  hyperkey = callPackage ./darwin/hyperkey.nix { };

  alttab = callPackage ./darwin/alttab.nix { };
  snipaste = callPackage ./darwin/snipaste.nix { };

  # yabai = darwin.apple_sdk.callPackage ./darwin/yabai.nix {
  #   inherit (apple_sdk.frameworks) SkyLight Cocoa Carbon ScriptingBridge;
  # };
  yabai = callPackage ./darwin/yabai.nix { };

  shiori = callPackage ./shiori.nix { };
  passage = callPackage ./passage.nix { };

  nixos-installer = callPackage ./nixos-installer { };
  v2ray-plugin = callPackage ./networking/v2ray-plugin.nix { };
  sing-box-prebuilt = callPackage ./networking/sing-box.nix { };
  chinadns-ng = callPackage ./networking/chinadns-ng.nix { };
  starlark-rust = callPackage ./starlark-rust.nix { };
  typst-prebuilt = callPackage ./darwin/typst.nix { };
  open-haskell-doc = callPackage ./darwin/scripts/open-haskell-doc.nix { };
  concealed-pbcopy = callPackage ./darwin/scripts/concealed-pbcopy.nix { };

  pbls-prebuilt = callPackage ./pbls.nix { };

  yazi-plugins = callPackage ./yazi { };

  ### linux
  zsh-vi-mode = callPackage ./zsh-vi-mode.nix { };
  create-ssh-session-gnupg-socketdir =
    callPackage ./linux/gnupg-socketdir.nix { };

  miniupnpc = callPackage ./miniupnpc.nix { };

}
