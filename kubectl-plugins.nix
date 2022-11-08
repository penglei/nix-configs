{pkgs, ...}@inputs:
  
let
  kubectx = pkgs.kubectx;

  nodeshell = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "kubectl-node-shell";
    version = "1.6.0";

    src = pkgs.fetchFromGitHub {
      owner = "kvaps";
      repo = "kubectl-node-shell";
      rev = "v${version}";
      sha256 = "sha256-dAsNgvHgquXdb2HhLDYLk9IALneKkOxQxKb7BD90+1E=";
    };

    strictDeps = true;
    buildInputs = [ pkgs.bash ];

    installPhase = ''
      runHook preInstall

      install -m755 ./kubectl-node_shell -D $out/bin/kubectl-node_shell

      runHook postInstall
    '';
  };

  kubectx-kubens = pkgs.runCommand "kubectx-kubens" {} ''
    mkdir -p $out/bin
    ln -sf ${kubectx}/bin/kubectx $out/bin/kubectl-ctx
    ln -sf ${kubectx}/bin/kubens $out/bin/kubectl-ns
  '';

in [ nodeshell kubectx-kubens ]
