# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

#{ config, pkgs, ... }:

{ config, pkgs, lib, ... }:
let
  nix-software-center = import (pkgs.fetchFromGitHub {
    owner = "vlinkz";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};

in

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    layout = "us";
    xkbModel = "logitech_base";
    xkbVariant = "altgr-intl";
    xkbOptions = "compose:ralt";
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
  ];

  services.gvfs.enable = true;    
  
  services.flatpak.enable = true;  
  services.blueman.enable = true;

  # Makes communicating between packages easier  
  services.dbus.enable = true; 

  # enable desktop portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  
  # Possible requirement to search on HDDs  
  services.udisks2.enable = true;
  services.udisks2.mountOnMedia = true;

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;  # suspect fixes bug when using headphones and shotcut

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
  musicDirectory = "/usr/share/music";
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
  security.pam.mount.enable = true; # should mount on login
  security.pam.services = {
    sddm.enableKwallet = true;
    swaylock.text = ''
      auth include login
      '';
  };

  # Enable OpenCL with Radeon Open Compute (ROCm)
  hardware = {
    opengl = { 
      enable = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk # Use AMD Vulkan drivers as needed
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

  programs.dconf = {
    enable = true;
  };

  nixpkgs.config = {
    # Allow proprietary packages
    allowUnfree = true;

    packageOverrides = pkgs: {
      # Enable the NUR
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;      
      };    
      unstable = import <nixos-unstable> { # pass the nixpkgs config to the unstable alias # to ensure `allowUnfree = true;` is propagated:
      config = config.nixpkgs.config;
      }; 
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.salgadev = {
    isNormalUser = true;
    home = "/home/salgadev";
    description = "Carlos Salgado";
    extraGroups = [ "plasma" "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "storage"	"video"]; 
    packages = with pkgs; [     
      wget
      neovim
      neofetch
      autojump
      brave       # private web browsing
      librewolf   # much more private     
      ungoogled-chromium # for compatibility
      celluloid
      gh          # github login
      git
      tldr
      variety     # wallpapers
      obs-studio  # screen recording	
      krusader # find duplicate files and more
      protonvpn-gui
      mailspring # easy sync with office365 
      joplin-desktop # notetaking gui
      gimp-with-plugins
      podman # handle containers, works with docker commands
      goverlay # gaming overlays
      openrgb-with-all-plugins 
      image-roll
      
      # Programming stuff
      jetbrains.pycharm-community
      vscodium
      python311Packages.pydevd
    ];
  };
  
  # Required for flatpaks
  fonts.fontDir.enable = true;

  fonts.fonts = with pkgs; [
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
  ];
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Plenty of bug fixes in these "unstable" wayland releases
    unstable.nwg-dock-hyprland
    unstable.hyprland-autoname-workspaces
    unstable.waybar # hyprland starts
    unstable.rofi-wayland 
    unstable.wl-clipboard
    unstable.swww
    unstable.xdg-utils
    unstable.hyprpicker
    pulseaudio # needed for media commands
    mako
    mpd # media playing daemon
    polkit-kde-agent
    libnotify
    kitty
    networkmanagerapplet
    jq
    hyprland-protocols
    swaylock-effects
    wofi
    wlogout
    swayidle
    swappy
    grim
    slurp
    python3Minimal
    python311Packages.requests_ntlm
    pamixer
    pavucontrol
    bluez
    bluez-tools
    blueman
    blueberry
    gnome.file-roller
    starship
    xfce.xfce4-taskmanager
    libsForQt5.sddm-kcm
    libsForQt5.kwallet-pam  # open wifi key on login
    kwalletcli # probably needed by polkit
    nur.repos.alarsyo.sddm-sugar-candy
    playerctl

    nix-software-center

    virt-manager
    wavpack # play wavs
    
    fontconfig # helps flatpaks    
    
    # trying out desktop apps
    cinnamon.nemo-with-extensions # explorer

    # Text editors
    libsForQt5.kate
    bluefish

    onlyoffice-bin

    # image viewers
    swayimg

    # document viewers
    mate.atril

    # Other utilities
    libsForQt5.kdeconnect-kde # SmartPhone Integration

    btop # system monitor
    killall 
    contour # modern terminal 

    pfetch # fast flex fetch
    clinfo # verify OpenCL works

    rar
    unzip

    xorg.xhost # possibly required by distrobox
    nur.repos.nltch.spotify-adblock
  ];
  
  # Add HIP support
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
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
  
  # flex on terminal launch
  programs.bash.shellInit = "pfetch";

  # Hyprland 
  programs ={
    hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
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
