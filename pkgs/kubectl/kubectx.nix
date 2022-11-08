{ kubectx, runCommand }:
runCommand "kubectx-kubens" { } ''
  mkdir -p $out/bin
  ln -sf ${kubectx}/bin/kubectx $out/bin/kubectl-ctx
  ln -sf ${kubectx}/bin/kubens $out/bin/kubectl-ns
''
