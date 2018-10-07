# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with pkgs.lib;
with pkgs.haskell.lib;

let
  unstableTarball = fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz;
  unstable = import unstableTarball {
               config = config.nixpkgs.config;
             };
  secrets = import ./secrets.nix;
in

{
  imports =
    [ ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

  hardware.bluetooth.enable = true;
  hardware.opengl.driSupport32Bit = true;
  
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true;

    tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = ["127.0.0.1"];
    };

#    extraConfig = ''
#      load-module module-switch-on-connect
#    '';
  };

  networking = {
    hostName = "schildpad";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22000 57621 ];
      allowedUDPPorts = [ 21027 57621 ];
      extraCommands = ''
        iptables -A INPUT -p udp --sport 1900 --dport 1025:65535 -j ACCEPT -m comment --comment spotify
        iptables -A INPUT -p udp --sport 5353 --dport 1025:65535 -j ACCEPT -m comment --comment spotify
      '';
    };
    
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    extraHosts = ''
      127.0.0.1 googlesyndication.com
      127.0.0.1 tpc.googlesyndication.com
      127.0.0.1 doubleclick.net
      127.0.0.1 g.doubleclick.net
      127.0.0.1 googleads.g.doubleclick.net
      127.0.0.1 www.google-analytics.com
      127.0.0.1 ssl.google-analytics.com
      127.0.0.1 google-analytics.com
      # 127.0.0.1 www.onclickmax.com
    '';

    # proxy.default = "http://127.0.0.1:8118";
    # proxy.noProxy = "localhost, 127.0.0.0/8, ::1, rutracker.org, libgen.io";
  };

  # Select internationalisation properties.
  i18n = {
     consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-m32n.psf.gz";
     consoleUseXkbConfig = true;
     defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile.

  nixpkgs.config = {

    allowUnfree = true;

    packageOverrides = pkgs: rec {
      isabelle = pkgs.isabelle.override {
        java = pkgs.openjdk10;
      };
    };
  };
  
  environment = {
  
    sessionVariables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      QT_STYLE_OVERRIDE = "adwaita";
      GTK_THEME = "Adwaita";
#      GTK_DATA_PREFIX = "${config.system.path}";
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
#      LIBGL_DISABLE_DRI3 = "1";
#      GDK_SCALE = "2";
    };
  
    systemPackages = with pkgs; with haskellPackages; [
      # desktop
      pkgs.st

#      adwaita-qt
      baobab
      calibre
      feh
      firefox-bin
      goldendict
      gthumb
      libreoffice
      mpv
      pavucontrol
      steam
      unstable.tdesktop
      zathura

      # system
      acpi
      bc
      coreutils
      dos2unix
      dvtm
      exiftool
      fdupes
      file
      findutils
      lm_sensors
      mc
      nox
      oathToolkit
      pamixer
      pciutils
      powertop
      psmisc
      p7zip
      silver-searcher
      tmuxPlugins.sensible
      udiskie
      unzip
      usbutils
      which
      xcalib
      xorg.xev
      xorg.xkill

      # development
      clang
      gdb
      gitAndTools.git
      gnumake
      haskellPackages.hlint
      manpages
      mercurial
      linuxPackages.perf
      sloccount
      haskellPackages.stylish-haskell
      haskellPackages.threadscope
      valgrind

      # networking
      cadaver
      dnsutils
      gnupg
      inetutils
      iw
      isync
      lftp
      mu
      nmap      

      # provers
      haskellPackages.Agda AgdaStdlib
      coq
      isabelle

      # publishing
      briss
      pkgs.exif
      pkgs.imagemagick
      pdftk
      xfig
    ];
  };
    
  fonts = {
    fonts = with pkgs; [
      cm_unicode
      font-awesome_4
      source-code-pro
      kochi-substitute
      terminus_font
      wqy_zenhei
    ];
  };

  programs = {
    adb.enable = true;
    bash.enableCompletion = true;
    fish.enable = true;
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    ssh.startAgent = false;
    slock.enable = true;
    tmux = {
      enable = true;         

      extraTmuxConf = ''
        set -g mouse on
        set -g prefix C-x
        bind-key C-x send-prefix
        unbind-key x
        bind-key k confirm-before -p "kill-pane #P? (y/n)" kill-pane

        set -g renumber-windows on
        set -g set-titles on
        set -g set-titles-string "[#I] #T"
        set -g status on
        set -g status-position top
        set -g status-left ""
        set -g status-right ""

        run-shell ${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux
      '';
    };   
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (subject.isInGroup('wheel') && subject.local) {
          return polkit.Result.YES;
        }
      });
  '';  

  # List services that you want to enable:

  services = {

    emacs = {
      enable = true;
      defaultEditor = true;
      #  package = unstable.emacs26.override { withGTK2 = false; withGTK3 = true; };
	    };

    illum.enable = true;

    mopidy = {
      enable = true;
      extensionPackages = [ pkgs.mopidy-spotify pkgs.mopidy-spotify-tunigo pkgs.mopidy-iris ];

      configuration = ''
[audio]
output = pulsesink server=127.0.0.1

[spotify]
username = ${secrets.spotify.username}
password = ${secrets.spotify.password}
client_id = ${secrets.spotify.client_id}
client_secret = ${secrets.spotify.client_secret}
bitrate = 320
      '';
    };

    openssh.enable = false;

    printing = {
      enable = true;
      drivers = [ pkgs.cups-bjnp pkgs.gutenprint ];
    };

    redshift = {
      enable = true;
      brightness = {
        day = "1.0";
        night = "0.7";
      };
      latitude = "57";
      longitude = "11";      
    };

    syncthing = {
      enable = true;
      dataDir = "/home/viv/.syncthing";
      user = "viv";
    };

    tor = {
      enable = true;
      client.enable = true;
    };

    transmission.enable = true;
    udisks2.enable = true;
        
    
    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      dpi = 160;

      layout = "us(colemak),ru";
      xkbOptions = "grp:rctrl_toggle,compose:prsc,caps:ctrl_modifier";

      libinput = {
        accelSpeed = "0.4";
        clickMethod = "clickfinger";
        disableWhileTyping = true;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        tapping = false;
      };

      desktopManager.default = "none";

      windowManager = {
        i3.enable = true;
        i3.extraPackages = with pkgs; [ dmenu unstable.i3status-rust i3lock ];

        default = "i3";
      };
    };
  };

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';

    services.powertop = {
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

    user = {
      services = {
    
        mbsync = {
          description = "Mailbox syncronization";

          serviceConfig = {
       	    Type      = "oneshot";
            ExecStart = "${pkgs.isync}/bin/mbsync -aq";
          };

       	  path = [ pkgs.gawk pkgs.gnupg ];

          after       = [ "network-online.target" "gpg-agent.service" ];
          wantedBy    = [ "default.target" ];
        };
      };

      timers = {
        mbsync = {
          description = "Mailbox syncronization";
      
          timerConfig = {
            OnCalendar = "*:0/15";
            Persistent = "true";
          };
          wantedBy = [ "timers.target" ];
        };
      };
    };
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.viv = {
    description = "Nikita Frolov";
    extraGroups = [ "wheel" "transmission" "adbusers" ];
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

}
