{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      <nixos-hardware/lenovo/thinkpad/x1/6th-gen>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = [
    { name = "nixos";
      device = "/dev/nvme0n1p4";
      preLVM = true; }
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9d8355f2-f02c-4bab-93b2-600296c085ff";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/6eddd9a6-4b62-438f-8dff-3abbca5408d7";
      fsType = "ext4";
    };


  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9E26-9A52";
      fsType = "vfat";
    };

  fileSystems."/windows" =
    { device = "/dev/disk/by-uuid/1EDA2966DA293B81";
      fsType = "ntfs-3g";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
