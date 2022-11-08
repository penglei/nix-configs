{ createscript, bash, ... }:

createscript "gnupg-socketdir" ./create-run-user-gnupg-socketdir.sh {
  dependencies = [ bash ];

  meta.description =
    "create ssh session gnu directory which contains forwarded gpg agent socket";
}

