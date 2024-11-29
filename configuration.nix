{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable experimental features
  nix.settings.experimental-features = [
    "nix-command"  # Enables nix-command (e.g., nix search)
    "flakes"       # Enables Flakes feature
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.password = "pegasus6";
  users.users.arath = {
    isNormalUser = true;
    description = "Aniket";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
  
  users.users.arath_admin = {
    isNormalUser = false;  # not normal user
    isSystemUser = true;  # system user,
    description = "Backup Admin Access account";
    extraGroups = [ "wheel" "networkmanager" ];  # (sudo access)
    password = "Rahul@8901";  # Set the password
    shell = pkgs.zsh;  # Use zsh or bash for a CLI shell
    group = "arath_admin";  # Create and assign to a specific group
    packages = with pkgs; [
	kdePackages.kate
  ];
  };
  users.groups.arath_admin = {};

  # Enable zsh
  programs.zsh.enable = true;
  # Install firefox.
  programs.firefox = {
    enable = true;
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Package Installs [ GLOBAL ] : chwck ONLINE @ search.nixos to get the pkgname
  environment.systemPackages = with pkgs; [
	vim
	wget
	pkgs.openssh
	pkgs.vscode
	pkgs.git
	pkgs.github-desktop
	pkgs.gparted
	pkgs.zsh
	pkgs.eza
	pkgs.bat
        pkgs.fzf
        pkgs.zoxide
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # Enable SSH Access
  services.openssh = {
    enable = true;  # Ensure OpenSSH service is enabled
    settings = {
      # Configure PasswordAuthentication (true or false depending on your needs)
      PasswordAuthentication = true;  # Or false, depending on your preference
    };
  };
  # List services that you want to enable:
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
