{ createscript, gnused }:

createscript "open-haskell-doc" ../../../scripts/open-haskell-doc {
  dependencies = [ gnused ];

  meta.description = "open haskell hoogle doc in alacritty";
}

