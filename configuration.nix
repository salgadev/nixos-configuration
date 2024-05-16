# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{

  imports = [ 
      ./hardware-configuration.nix # must have      
    ];

  # Use latest LTS kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # CPU scaling driver
  boot.kernelModules = [ "amd-pstate" ];
  boot.kernelParams = [ 
    "amd_pstate=active"
  ];

  # enable correct drivers for Vega 56 (Vega 10)
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Enable mounting shared ntfs partitions
  boot.supportedFilesystems = ["ntfs" "fat32" "ext4" "exfat" "btrfs"];
  
  # Prevent dual-boot to mess with clock
  time.hardwareClockInLocalTime = true;

  # Bootloader.
  # boot.loader.systemd-boot.enable = true; # working before  
  # Use the grub (to keep Windows install) EFI boot loader.
  boot.loader.timeout = 10;
  boot.loader.grub = {
	enable = true;
	useOSProber = true;
	device = "nodev"; 
	efiSupport = true;
	configurationLimit = 25;
	};
  boot.loader.efi = {
	canTouchEfiVariables = true;
	};
  
  # Mount shared HDD
  fileSystems."/mnt/data" = {
    device = "/dev/sda2";
    fsType = "ntfs";
    options = [ "defaults" ];
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
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  services.gnome.sushi.enable = true; # for nemo
  
  services.displayManager = {    
    sddm = {      
      enable = true;  
      wayland.enable = true;
      };
  };
  
  # Plasma 5 Exclusions
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    okular
    oxygen
    khelpcenter
    print-manager
    gwenview
    spectacle
    elisa
    kwrited
  ];
    
  services = {
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
  };
  

  # enable desktop portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
#    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;  # suspect fixes bug when using headphones and shotcut

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  
  hardware.pulseaudio = { 
    enable = false;
    extraConfig = "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";
    };

  services.mpd = {
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
    mount.enable = true; # should mount on login
    services = {
      sddm.enableKwallet = true;
      swaylock.text = ''
        auth include login
        '';
    };
  };

  # Enable OpenCL with Radeon Open Compute (ROCm)
  hardware = {
    opengl = { 
      enable = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk # Use AMD Vulkan drivers as needed
	vaapiVdpau
        libvdpau-va-gl
      ];
      driSupport = true;    
      driSupport32Bit = true;
    };
    bluetooth.enable = true;
  };
  
  virtualisation = {
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

    # Seems spotify is dead/broken today
    /*
    packageOverrides = pkgs: {
      # Enable the NUR
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;      
      };          
    };
    */
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.salgadev = {
    isNormalUser = true;
    home = "/home/salgadev";
    description = "Carlos Salgado";
    extraGroups = [ "plasma" "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "storage"	"video"]; 
    packages = with pkgs; [     
      wget      
      autojump
      gh          # github login
      git
      tldr
      variety     # wallpapers
      obs-studio  # screen recording	
      krusader # find duplicate files and more
      betterbird # email
      joplin-desktop # notetaking gui
      libsForQt5.kate # text editor
      apostrophe # Markdown editor      
      freeoffice
      rclone
      rclone-browser
      # design apps
      # gimp-with-plugins 
      # inkscape-with-extensions

      # browsers 
      brave       # private web browsing
      ungoogled-chromium # for compatibility

      # media
      qmplay2
    ];
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
   
  environment.systemPackages = with pkgs; [     
    # hyprland requirements
    waybar
    hyprland-autoname-workspaces
    hyprland-protocols
    rofi-wayland
    mako
    swww
    xdg-utils
    hyprpicker
    wf-recorder
    polkit-kde-agent
    polkit_gnome
    libnotify
    kitty
    networkmanagerapplet
    jq
    swappy
    slurp
    grim
    cliphist
    wl-clipboard

    # screenlock
    swaylock-effects
    wlogout
    swayidle
    hypridle
    hyprlock

    # audio/media commands
    pulseaudio 
    pamixer
    pavucontrol

    # bluetooth
    bluez
    bluez-tools
    starship
    gdu
    ncdu
    xfce.xfce4-taskmanager

    # Nemo File Manager
    cinnamon.nemo-with-extensions
    cinnamon.nemo-fileroller
    cinnamon.nemo-python
    cinnamon.folder-color-switcher
    nemo-qml-plugin-dbus

    libsForQt5.sddm-kcm
    libsForQt5.kwallet-pam  # open wifi key on login
    kwalletcli # probably needed by polkit
    
    haruna # video player 
    playerctl # media
    wavpack # play wavs   
    #nur.repos.nltch.spotify-adblock

    fontconfig # helps flatpaks
    
    baobab # storage visualizer
    swayimg # image viewer
    
    mate.atril # document viewers

    # Other utilities
    killall
    libsForQt5.kdeconnect-kde # SmartPhone Integration

    btop # system monitor

    pfetch # fast flex fetch
    clinfo # verify OpenCL works

    rar
    alejandra

    # icons
    papirus-icon-theme

    xorg.xhost # possibly required by distrobox    
        
    chntpw # fix windows registrt util

    jetbrains.pycharm-community
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
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
        
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
  
  # Add HIP support
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Start polkit-kde as a systemd service
  systemd = {
  user.services.polkit-kde-authentication-agent-1 = {
    description = "polkit-kde-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
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
    direnv.enable = true;
    dconf.enable = true; 
    virt-manager.enable = true;    
    nix-ld.enable = true; # Helps VSCodium
  };
  
  # flex
  environment.shellInit = "pfetch";

  # Hyprland 
  programs ={
    xwayland.enable = true;
    hyprland = {
      enable = true;
      #package = pkgs.unstable.hyprland;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  # Flatpak terminal shortcuts
  environment.shellAliases = {
    shotcut = "org.shotcut.Shotcut"; # outdated in nixpkgs
  };

  environment.sessionVariables = {
    # Helps Chromium and Electron apps
    NIXOS_OZONE_WL = "1";
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
  system.stateVersion = "23.05"; # Did you read the comment?

}