{ createscript, coreutils }:

createscript "make-vm-disk" ./make-vm-disk.sh {
  dependencies = [ coreutils ];

  meta.description = "a tool contains nixos installation summary steps";
}

