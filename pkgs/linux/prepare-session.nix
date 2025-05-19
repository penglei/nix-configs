{ createscript, bash, ... }:

createscript "entrypoint" ./prepare-session.sh {
  dependencies = [ bash ];
  meta.description = "prepare user login session directories";
}
