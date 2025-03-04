# /etc/nixos/configuration.nix > "Location"

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Enable experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "lenevo-sh0r3s"; # Define your hostname.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
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
  networking.hosts = {
    "127.0.0.1" = [ "host.jenkins.internal" ];
  };
  # Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Services
  services.printing.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    #media-session.enable = true;
  };
  # services.xserver.libinput.enable = true; # touchpad support
  users.users.arath = {
    isNormalUser = true;
    description = "Aniket Rath";
    extraGroups = [ "networkmanager" "wheel" "video" "audio"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      eza
      bat
      fzf
      zoxide
      github-desktop
      vscode
    ];
  };
  # Packages
  programs.firefox.enable = true;
  services.jenkins = {
    enable = true;
    # extraGroups = [ "podman" ];
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "darkblood";
    };

    shellAliases = {
      ll = "eza -lh";
      lh = "eza -alh";
      ls = "eza";
      c = "clear";
      e = "exit";
      update = "sudo nixos-rebuild switch";
    };
    histSize = 10000;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    openssh
    git
    gparted
    zsh
    dive
    podman-tui
    podman-compose
    udev-gothic-nf
  ];
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh = {
  enable = true;
  ports = [ 22 ];
  settings = {
    PasswordAuthentication = true;
    AllowUsers = [ "sh0r3s" ];
    UseDns = true;
    X11Forwarding = false;
    PermitRootLogin = "yes";
  };
};
  # Virtualisation services :
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "jenkins" "arath" ];
  hardware.nvidia-container-toolkit.enable = true;
  # List services that you want to enable:
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
