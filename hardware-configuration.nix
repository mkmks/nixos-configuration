{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    earlyVconsoleSetup = true;

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

  # ThinkPad X1 6G QHD (copied from nixos-hardware)

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    trackpoint = {
      enable = true;
      emulateWheel = true;
      sensitivity = 100;
      speed = 80;
    };
    usbWwan.enable = true;
  };

  systemd.services = {
    cpu-throttling = {
      enable = true;
      description = "Sets the offset to 3 °C, so the new trip point is 97 °C";
      documentation = [ "https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#Power_management.2FThrottling_issues"
      ];
      path = [ pkgs.msr-tools ];
      script = "wrmsr -a 0x1a2 0x3000000";
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [
        "timers.target"
      ];
    };

    powertop = {
      description = ''
        enables powertop's recommended settings on boot
      '';
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ powertop ];

      environment = {
        TERM = "dumb";
      };

      serviceConfig = {
        Type = "idle";
        User = "root";
        ExecStart = ''
          ${pkgs.powertop}/bin/powertop --auto-tune
        '';
      };
    };
  };

  systemd.timers.cpu-throttling = {
    enable = true;
    description = "Set cpu heating limit to 97 °C";
    documentation = [
      "https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#Power_management.2FThrottling_issues"
    ];
    timerConfig = {
      OnActiveSec = 60;
      OnUnitActiveSec = 60;
      Unit = "cpu-throttling.service";
    };
    wantedBy = [
      "timers.target"
    ];
  };

  services.tlp = {
    enable = lib.mkDefault true;
    extraConfig = ''
      START_CHARGE_THRESH_BAT0=75
      STOP_CHARGE_THRESH_BAT0=80
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      ENERGY_PERF_POLICY_ON_BAT=powersave
    '';
  };
}
