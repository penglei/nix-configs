{ config, ... }: {
  microvm.writableStoreOverlay = "/nix/.rw-store";

  microvm.volumes = [{
    image = "nix-store-overlay.img";
    mountPoint = config.microvm.writableStoreOverlay;
    size = 2048;
  }];
}
