# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # must have
     <home-manager/nixos>
  ];

  # Prevent dual-boot to mess with clock
  time.hardwareClockInLocalTime = true;
  
  # Use latest LTS kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    
    # CPU scaling driver
    kernelModules = ["amd-pstate"];
    kernelParams = ["amd_pstate=active"];
    
    # enable correct drivers for Vega 56 (Vega 10)
    initrd.kernelModules = ["amdgpu"];
    
    # Enable mounting shared ntfs partitions
    supportedFilesystems = ["ntfs" "fat32" "ext4" "exfat" "btrfs"];

    loader = {
      timeout = 10;
      grub = {
        enable = true;
        useOSProber = true;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 1;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };  
  
  # Mount shared HDD
  fileSystems."/mnt/data" = {
    device = "/dev/sda2";
    fsType = "ntfs";
    options = ["defaults"];
  };
  # Gaming partition
  #fileSystems."/mnt/games" = {
  #  device = "/dev/nvme1n1p2";
  #  fsType = "ntfs";
  #  options = [ "defaults" ];
  #};
  # Windows Partition
  #fileSystems."/mnt/win10" = {
  #  device = "/dev/nvme0n1p4";
  #  fsType = "ntfs";
  #  options = [ "defaults" ];
  #};

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  stylix = {
    enable = true;    
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # polarity = "dark"; # breaks base16Scheme for some reason
    image = /usr/share/backgrounds/lpz/LaPazAtardecer.jpg;    

    homeManagerIntegration.autoImport = true;
    autoEnable = true;
    opacity.terminal = 0.9;
        
    cursor  = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePineDawn-Linux";
      size = 32;
    };    

    fonts.sizes = {
      terminal = 16;
    };

    targets = {
      grub.enable = true;
      gnome.enable = true;
      gtk.enable = true;
    };    
  };

  services = {
    ollama = {
      enable = true;
      acceleration = "rocm";
    };    

    openvpn.servers = {
      tryhackme = {
        config = "config /home/salgadev/code/tryhackme/salgadev.ovpn";
        autoStart = false;        
      };
    };  

    xserver = {      
      enable = true;      
    };

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-sddm-corners";      
    };              
    
    gnome = {      
      gnome-keyring.enable = true; # for WiFi
      glib-networking.enable = true;
      at-spi2-core.enable = true;
    };
    
    mpd = {
      enable = true;
      musicDirectory = "/home/salgadev/Music";
      extraConfig = ''
          audio_output {
            type "pulse"
            name "PulSonido"
            server "127.0.0.1" # must connect to the local sound server
        }
      '';
      # Optional:
      network.listenAddress = "any"; # if you want to allow non-localhost connections
      startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Makes communicating between packages easier
    dbus.enable = true;

    # Automount / Search HDDs
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;

    # bluetooth
    blueman.enable = true;

    # Thumbnails
    tumbler.enable = true;

    flatpak.enable = true;
    # cinnamon clashing with already installed nemo
    # cinnamon.apps.enable = true;
  };

  # enable desktop portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # sound.enable = true;
  security.rtkit.enable = true;

  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
    extraConfig = "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";
  };

  # enable and configure polkit to automount drives
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("wheel")
          && (/^org\.freedesktop\.udisks\./.test(action.id)
          ))
            { return polkit.Result.YES; }
      });
    '';
  };

  # auto connect to wifi on wayland
  security.pam = {
    services.gdm-password.enableGnomeKeyring = true;
    mount.enable = true; # should mount on login
    services = {
      sddm.enableKwallet = true;
      swaylock.text = ''
        auth include login
      '';
    };
  };

  hardware = {
    graphics = {     
      enable = true;
      # enable32Bit = true; unstable option
      extraPackages = with pkgs; [
        rocmPackages.clr.icd # broken in unstable
        amdvlk # Use AMD Vulkan drivers as needed        
        ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
        ];
    };    
    bluetooth.enable = true;
  };

  virtualisation = {
    # Enable common container config files in /etc/containers
    containers.enable = true;

    libvirtd.enable = true;
    podman = {
      enable = true;
      # Create a `docker` alias for podman,
      # to use it as a drop-in replacement
      dockerCompat = true;

      # required for podman-compose
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  nixpkgs.config = {
    # Allow proprietary packages
    allowUnfree = true;
    packageOverrides = pkgs: {
      # Enable the NUR
      nur = import (builtins.fetchTarball {
        url = "https://github.com/nix-community/NUR/archive/3a6a6f4da737da41e27922ce2cfacf68a109ebce.tar.gz";
        sha256 = "04387gzgl8y555b3lkz9aiw9xsldfg4zmzp930m62qw8zbrvrshd"; 
      }) {
        inherit pkgs;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.salgadev = {
    isNormalUser = true;
    home = "/home/salgadev";
    description = "Carlos Salgado";
    extraGroups = ["networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "storage" "video"];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.salgadev = {pkgs, ...}:{    
    nixpkgs.config.allowUnfreePredicate = (_: true); 
    home.packages = with pkgs; [
      wget
      autojump
      git
      gh # github login
      
      tldr      
      obs-studio # screen recording
      krusader # find duplicate files and more
      #betterbird # email
      joplin-desktop # notetaking gui      
      apostrophe # Markdown editor
      freeoffice
      rclone
      rclone-browser
      brave # private web browsing
      ungoogled-chromium # for compatibility
      floorp 
      oculante
      imv
      mpv
      oterm
      alpaca
      gpt4all      
    ];
    programs.bash.enable = true;

    home.stateVersion = "24.05";
  };

  # Required for flatpaks
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    font-awesome # for hyprland theme
    material-design-icons # for neofetch theme
    jetbrains-mono
    victor-mono
    terminus-nerdfont
    nixos-icons
    zafiro-icons
    merriweather
    merriweather-sans
  ]; 

  # List packages installed in system profile. To search, run:
  # $ nix search wget  
  environment = {
    shellInit = "pfetch"; # flex  
    # Flatpak shortcuts
    shellAliases = {
      shotcut = "org.shotcut.Shotcut"; # outdated in nixpkgs
    };
    sessionVariables = {
      # Helps Chromium and Electron apps
      NIXOS_OZONE_WL = "1";
    };
    
    systemPackages = with pkgs; [
      config.nur.repos.nltch.spotify-adblock
      distrobox

      # sddm
      catppuccin-sddm-corners
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols2

      # wayfire
      satty # screenshots
      foot
      clipse
      alsa-utils # volume control
      tdrop            
      waybar
      rofi-wayland
      # mako
      fnott
      xdg-utils
      hyprpicker
      wf-recorder
      # polkit-kde-agent
      # polkit_gnome
      libnotify
      kitty
      networkmanagerapplet
      jq 
      slurp
      grim
      cliphist
      wl-clipboard

      # screenlock
      # swaylock-effects
      swaylock
      wlogout
      swayidle

      # audio/media commands
      # pulseaudio
      pavucontrol
      # pamixer

      # bluetooth
      bluez
      bluez-tools

      starship
      gdu
      ncdu
      xfce.xfce4-taskmanager

      # Nemo File Manager
      # already using cinnamon as backup DE
      nemo-with-extensions
      nemo-fileroller
      nemo-python
      folder-color-switcher
      nemo-qml-plugin-dbus

      kdePackages.kwallet

      playerctl # media
      wavpack # play wavs
      fontconfig # helps flatpaks
      baobab # storage visualizer

      mate.atril # document viewers

      # Other utilities
      killall
      libsForQt5.kdeconnect-kde # SmartPhone Integration
      pfetch # fast flex fetch
      clinfo # verify OpenCL works

      # podman
      dive            # look into docker image layers
      podman-tui      # status of containers in the terminal    
      podman-compose  # start group of containers for dev

      rar
      alejandra
      
      # Theming
      gnome-tweaks
      glib
      themechanger
      ncpamixer
            
      # GTK themes
      gtk-engine-murrine
      # catppuccin-gtk
      magnetic-catppuccin-gtk
      rose-pine-gtk-theme
      config.nur.repos.ataraxiasjel.rosepine-gtk-icons

      # Icons
      colloid-icon-theme
      rose-pine-icon-theme # last update 2022
      kora-icon-theme
      reversal-icon-theme

      chntpw # fix windows registrt util

      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions;
          [
            # theming
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons

            # python
            ms-python.vscode-pylance
            ms-python.black-formatter
            ms-toolsai.jupyter
            ms-toolsai.jupyter-renderers
            ms-toolsai.vscode-jupyter-cell-tags
            ms-toolsai.jupyter-keymap
            ms-toolsai.vscode-jupyter-slideshow

            # nix
            bbenoist.nix
            kamadorueda.alejandra
            jnoortheen.nix-ide

            # markdown
            yzhang.markdown-all-in-one
            bierner.markdown-mermaid

            # misc
            usernamehw.errorlens

            # remotes
            ms-azuretools.vscode-docker
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh

            # AI Tools
            continue.continue
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "remote-ssh-edit";
              publisher = "ms-vscode-remote";
              version = "0.47.2";
              sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
            }
            {
              name = "python";
              publisher = "ms-python";
              version = "2024.5.11021008";
              sha256 = "52723495e44aa82b452c17464bf52f2ee09cc508626f26340a19b343dbb2b686";
            }                    
          ];
      })
    ];
  };  

  # Seems broken July 2024 
  # Add HIP support
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Start polkit-kde as a systemd service
  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs = {    
    # Window managers
    wayfire = {
      enable = true;
      plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
    };
    xwayland.enable = true;    
    direnv.enable = true;
    dconf.enable = true;
    virt-manager.enable = true;
    nix-ld.enable = true; # Helps VSCodium
  };

  # List services that you want to enable:

  # Likely not being used
  # Enable the OpenSSH daemon.
  #services.openssh = {
  #  enable = true;
  #  settings.X11Forwarding = true;
  #  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
