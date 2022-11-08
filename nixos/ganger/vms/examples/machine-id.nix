# backup of: https://git.eisfunke.com/config/nixos/-/blob/284da0c26b54466bc0b2cc6c9a8f966a63849f61/nixos/machine-id.nix
# https://git.eisfunke.com/config/nixos/-/blob/main/nixos/machine-id.nix

/* This module sets the machineId used by systemd.

   The machineId should stay the same. If it doesn't, it will lead to problems. E.g. with
   systemd-journald: journald will start a new journal at `/var/log/journal/$MACHINEID` at every
   boot. That means logs from previous boots won't be shown – and also never be cleaned up. This
   means over time `/var/log` will grow indefinitely.

   Notes:
   - the machineId should be handled confidentially!
   - that's why I don't derive the hostId from it anymore
   - building a derivation with the hostId based on the machineId as a secret is complex
   - the hostId needs to be available in the initramfs so it can't just be another agenix secret or
     something like that
   - so I just set it manually on my one device that uses ZFS
   - while the hostId is also set in the initrd, which is necessary because ZFS is mounted there, the
     machine-id isn't and couldn't be, because the secrets aren't available there
   - the initrd has to live with having transient machineIds, I guess

   See:
   - https://www.freedesktop.org/software/systemd/man/latest/machine-id.html
   - https://github.com/NixOS/nixpkgs/pull/286140
*/

{ pkgs, config, res, ... }:

let
  /* We create a symlink file that links to the actual machine-id secret. This is necessary because
     if we used the secret file directly as source in environment.etc, it would be copied into the
     store, potentially breaking confidentiality.

     Adapted from home-manager's `mkOutOfStoreSymlink`:
     https://github.com/nix-community/home-manager/blob/c0ef0dab55611c676ad7539bf4e41b3ec6fa87d2/modules/files.nix#L64
  */
  machineIdFile = pkgs.runCommandLocal "machine-id-link" { } ''
    ln -s ${config.age.secrets."machine-id".path} $out
  '';
in {
  # the secret is defined here in order to only add its own id for each host
  age.secrets.machine-id = {
    file = res + /secrets/machine-id-${config.networking.hostName}.age;
    owner = "root";
    group = "root";
    # the machine-id needs to be accessible by everyone (otherwise networking won't work)
    mode = "444";
  };

  environment.etc.machine-id.source = machineIdFile;
}

