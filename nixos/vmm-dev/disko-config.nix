{
  disko.devices.disk = {
    main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          biosboot = {
            size = "1M";
            type = "EF02"; # BIOS boot partition for grub, no EFI on this VM
            attributes = [ 0 ];
          };
          root = {
            size = "100%";
            # Pin the device: by-partlabel symlinks are not reliably present
            # right after sgdisk/udevadm settle in the kexec installer.
            device = "/dev/vda2";
            content = {
              type = "filesystem";
              format = "ext4";
              # The old xfs root leaves secondary superblocks inside the new
              # partition, so mke2fs needs -F to skip its overwrite prompt.
              extraArgs = [
                "-F"
                "-L" "nixos"
              ];
              mountpoint = "/";
            };
          };
        };
      };
    };

    data = {
      type = "disk";
      device = "/dev/vdb";
      content = {
        type = "gpt";
        partitions = {
          data = {
            size = "100%";
            device = "/dev/vdb1";
            content = {
              type = "filesystem";
              format = "btrfs";
              # Old ext4 backup superblocks survive the wipe of the disk header.
              extraArgs = [
                "-f"
                "-L" "data"
              ];
              mountpoint = "/data";
            };
          };
        };
      };
    };
  };
}
