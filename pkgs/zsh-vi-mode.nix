{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "zsh-vi-mode";
  version = "master";

  src = fetchFromGitHub {
    owner = "jeffreytse";
    repo = pname;
    rev = "1bda23100e8d140a19be0eed67395c64f6a6074c";
    hash = "sha256-3arAa5EBG+U9cCauChX9K0KF3hkd+t04/trlWKk/gOw=";
  };

  strictDeps = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/${pname}
    cp *.zsh $out/share/${pname}/
  '';

  meta = with lib; {
    homepage = "https://github.com/jeffreytse/zsh-vi-mode";
    license = licenses.mit;
    description = "A better and friendly vi(vim) mode plugin for ZSH.";
    maintainers = with maintainers; [ kyleondy ];
  };
}

