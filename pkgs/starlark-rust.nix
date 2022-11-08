{ stdenv, lib, fetchFromGitHub, rustPlatform, libiconv }:

rustPlatform.buildRustPackage rec {
  pname = "startlark-rust";
  version = "main";

  cargoSha256 = "sha256-xtyauG9kbTNclWrxlnz79hSypf77gtYgAi6ktjeL6W4=";
  src = fetchFromGitHub {
    owner = "penglei";
    repo = "starlark-rust";
    rev = "00f79079ad2355a6929c6b7bfc90c8417b886d60";
    hash = "sha256-iJLL2FTSa/ur5jwc9PgZThJhnyRxUf225DeWFcQHQQU=";
  };

  buildInputs = [ ] ++ lib.optionals stdenv.isDarwin [ libiconv ];

  meta = with lib; {
    description = "Rust implementation of the Starlark language";
    homepage = "https://github.com/facebookexperimental/starlark-rust";
    platforms = platforms.unix;
  };
}

