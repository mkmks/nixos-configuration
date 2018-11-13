{ config, pkgs, ... }:

with pkgs.lib;
with pkgs.haskell.lib;

let
  unstableTarball = fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz;
  unstable = import unstableTarball {
               config = config.nixpkgs.config;
             };
in

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    cleanTmpDir = true;
  };
  
  hardware = {
    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];  
    };

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
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

  i18n = {
     consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-m32n.psf.gz";
     consolePackages = [ pkgs.terminus_font ];
     consoleUseXkbConfig = true;
     defaultLocale = "fr_FR.UTF-8";
  };

  time.timeZone = "Europe/Stockholm";

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
      GDK_SCALE = "2";
      GDK_DPI_SCALE= "0.5";
      GTK_THEME = "Adwaita:dark";
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
    };
  
    systemPackages = with pkgs; with haskellPackages; [
      # desktop
      google-chrome
      libreoffice
      skypeforlinux
      spotify
      steam
      unstable.tdesktop

      gnome3.adwaita-icon-theme
      gnome3.dconf-editor
      gnome3.eog
      gnome3.gnome-themes-extra      
      gnome3.libsecret
      gnome3.seahorse
      baobab
      gthumb
      pavucontrol

      unstable.adwaita-qt
      calibre
      goldendict
      qpdfview
      vlc

      # base
      acpi
      bc
      coreutils
      dnsutils
      file
      findutils
      inetutils
      iw
      lm_sensors
      msmtp
      pamixer
      pciutils
      psmisc
      unzip
      which
      usbutils
      xorg.xev
      xorg.xkill

      # base-extra
      dos2unix
      exiftool
      fdupes
      mc
      nox
      powertop
      p7zip
      silver-searcher
      tmuxPlugins.sensible
      udiskie
      xcalib

      # dev
      clang
      gdb
      gnumake
      manpages

      # dev-extra
      gitAndTools.git
      mercurial
      sloccount
      valgrind
      linuxPackages.perf
      haskellPackages.hlint
      haskellPackages.stylish-haskell
      haskellPackages.threadscope

      # networking
      gnupg
      isync
      lftp
      mu
      nmap      

      # provers
      haskellPackages.Agda AgdaStdlib
      coq
      isabelle

      # publishing
      pkgs.exif
      pkgs.imagemagick
      pdftk
      xfig
    ];
  };
    
  fonts = {
    fontconfig.dpi = 210;
    fonts = with pkgs; [
      cm_unicode
      font-awesome_4
      source-code-pro
      kochi-substitute
      wqy_zenhei
    ];
  };

  programs = {
    adb.enable = true;
    bash.enableCompletion = true;
    dconf.enable = true;
    fish.enable = true;    
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    qt5ct.enable = true;
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

  security = {
    pam.services.lightdm.enableGnomeKeyring = true;

    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (subject.isInGroup('wheel') && subject.local) {
            return polkit.Result.YES;
          }
      });
    '';
  };

  services = {
    dbus.packages = [ pkgs.gnome3.dconf ];
    gnome3.gnome-keyring.enable = true;

    emacs = {
      enable = true;
      defaultEditor = true;
	  };

    fstrim.enable = true;
    gpm.enable = true;
    illum.enable = true;

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

    privoxy = {
      enable = false;
      enableEditActions = true;
    };

    tor = {
      enable = false;
      client.enable = true;
    };

    transmission.enable = true;
    transmission.home = "/home/transmission";
    udisks2.enable = true;
        
    xserver = {
      enable = true;

      dpi = 210;

      layout = "us(colemak),ru";
      xkbOptions = "grp:rctrl_toggle,compose:prsc,caps:ctrl_modifier";

      libinput = {
        enable = true;
        accelProfile = "flat";
        accelSpeed = "0.5";
        clickMethod = "clickfinger";
        disableWhileTyping = true;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        tapping = false;
      };

      desktopManager.default = "none";

      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [ dmenu i3status i3lock ];
          extraSessionCommands = ''
            xcalib /etc/X11/B140QAN02_0_02-10-2018.icm
            xsetroot -bg black
            xsetroot -cursor_name left_ptr

            if [ -d "$XDG_RUNTIME_DIR/gnupg/" ]; then
                export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
                ${pkgs.gnupg}/gpg-connect-agent -q updatestartuptty /bye
            fi
          '';
        };        

        default = "i3";
      };
    };
  };

  systemd = {

    user = {
      services = {    
        mbsync = {
          description = "Mailbox syncronization";

          serviceConfig = {
       	    Type      = "oneshot";
            ExecStart = "${pkgs.isync}/bin/mbsync -aq";
          };

       	  path = [ pkgs.gnome3.libsecret ];

          after       = [ "network-online.target" ];
          wantedBy    = [ "default.target" ];
        };

        udiskie = {
          description = "Automounter for removable media";

          serviceConfig = {
            ExecStart = "${pkgs.udiskie}/bin/udiskie -f ''";
            Restart   = "always";
          };

          wantedBy = [ "default.target" ];
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

  users.users.viv = {
    description = "Nikita Frolov";
    extraGroups = [ "wheel" "transmission" "adbusers" ];
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
  };

  system.stateVersion = "18.09";
}
