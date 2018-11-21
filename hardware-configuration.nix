{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };    

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "i915" ];
      luks.devices = [
        { name = "nixos";
          device = "/dev/nvme0n1p5";
          preLVM = true; }
      ];
    };
    
    kernelModules = [ "kvm-intel" "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  fileSystems = {
    "/" =
    { device = "/dev/disk/by-uuid/9d8355f2-f02c-4bab-93b2-600296c085ff";
      fsType = "ext4";
    };

    "/home" =
    { device = "/dev/disk/by-uuid/6eddd9a6-4b62-438f-8dff-3abbca5408d7";
      fsType = "ext4";
    };


    "/boot" =
    { device = "/dev/disk/by-uuid/9E26-9A52";
      fsType = "vfat";
    };

    "/openbsd" =
    { device = "/dev/disk/by-uuid/5be3f57ef9f3024e";
      fsType = "ufs";
      options = [ "ufstype=44bsd" ];
    };    

    "/windows" =
    { device = "/dev/disk/by-uuid/1EDA2966DA293B81";
      fsType = "ntfs-3g";
    };
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;

}
