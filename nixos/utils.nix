{
  gen_mac = s:
    let
      hash = builtins.hashString "sha256" s;
      c = off: builtins.substring off 2 hash;
    in "${builtins.substring 0 1 hash}2:${c 2}:${c 4}:${c 6}:${c 8}:${c 10}";
}
