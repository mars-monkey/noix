{
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" ];
    kernelModules = [ "kvm-intel" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    zfs.devNodes = "/dev/disk/by-partlabel";
  };

  fileSystems = {
    "/" = {
      device = "inspiron7506-zroot/state/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "inspiron7506-zroot/built/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "inspiron7506-zroot/safe/home";
      fsType = "zfs";
      # Required for `hashedPasswordFile` etc. to work properly
      neededForBoot = true;
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/inspiron7506-zboot";
      fsType = "vfat";
      neededForBoot = false;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostId = "1afade11";

  system.stateVersion = "24.11";
}
