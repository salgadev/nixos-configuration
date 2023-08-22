# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # enable correct drivers for Vega 56 (Vega 10)
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Enable mounting shared ntfs partitions
  boot.supportedFilesystems = ["ntfs" "fat32" "ext4"];
  
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

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    layout = "us";
    xkbVariant = "symbolic";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable OpenCL with Radeon Open Compute (ROCm)
  hardware.opengl.extraPackages = with pkgs; [
	rocm-opencl-icd
	rocm-opencl-runtime
	amdvlk # Use AMD Vulkan drivers as needed
  ];
  
  # Enable Vulkan/OpenGL
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.salgadev = {
    isNormalUser = true;
    home = "/home/salgadev";
    description = "Carlos Salgado";
    # extraGroups = [ "networkmanager" "wheel" ]; # after graphical install
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [     
	wget
	neovim
        autojump
        starship
        brave
        librewolf       
	celluloid
	feh
	flameshot
	fontconfig
	gh
	git
	kitty
	pavucontrol
	swaycons
	tldr
	unzip
	variety
	youtube-tui
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
	mpv
	clinfo # verify OpenCL works
  ];
  
  # Add HIP support
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
