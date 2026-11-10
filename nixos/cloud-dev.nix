{
  hostname,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./modules/keeping.nix
    ./modules/tat-agent.nix
  ];
  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
  };

  boot.loader.timeout = 1;
  boot.kernelModules = [ "wireguard" ];

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    useNetworkd = true;
    nftables.enable = true;
  };

  services.openssh = {
    ports = [
      22
      36000
    ];
  };

  #this also enable 'services.resolved'
  systemd.network.enable = true;
  systemd.services."systemd-networkd" = {
    environment.SYSTEMD_LOG_LEVEL = "debug";
  };

  #This is important for vscode server
  programs.nix-ld.enable = true;

  # Without swap a runaway process (e.g. codelldb) makes the kernel thrash on
  # file-backed pages instead of OOM-killing: the box hangs with OOMKills=0.
  # zram gives oomd a swap signal; pressure rules kill the offending cgroup early.
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
  systemd.oomd = {
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };
  # Kill the largest swap consumer before zram fills up (Fedora default).
  systemd.slices."-".sliceConfig.ManagedOOMSwap = "kill";

  services.timesyncd.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    tcpdump
    python3
    buildah
    skopeo
    podman
    iotop
    iftop

    unzip
  ];
  system.stateVersion = "23.05";
}
