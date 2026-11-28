# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  host,
  username,
  ...
}:
let
  inherit (import ./variables.nix)
    wallpaper
  ;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../system/system.nix
      ../../system/system-packages.nix
      ../../system/desktop-packages.nix
      ../../system/desktop-base.nix
      # ../../system/window-systems
      ../../system/fonts.nix
      ../../system/steam.nix
      # ../../system/tailscale.nix
      # ../../system/virtualisation.nix
      ../../modules/amd-drivers.nix
      ../../modules/intel-drivers.nix
      ../../modules/nvidia-drivers.nix
      ../../modules/nvidia-prime-drivers.nix

      # ./secrets
    ];

  boot.loader = {
    timeout = 3;

    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI isn't generated
      devices = ["nodev"];
      useOSProber = true;
    };
  };
  boot.initrd.kernelModules = [];

  networking.hostName = "${host}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  time.hardwareClockInLocalTime = true;

  # Styling Options
  stylix = {
    enable = true;
    image = ../../config/wallpapers/${wallpaper};

    # base16Scheme = {
    #   base00 = "232136";
    #   base01 = "2a273f";
    #   base02 = "393552";
    #   base03 = "6e6a86";
    #   base04 = "908caa";
    #   base05 = "e0def4";
    #   base06 = "e0def4";
    #   base07 = "56526e";
    #   base08 = "eb6f92";
    #   base09 = "f6c177";
    #   base0A = "ea9a97";
    #   base0B = "3e8fb0";
    #   base0C = "9ccfd8";
    #   base0D = "c4a7e7";
    #   base0E = "f6c177";
    #   base0F = "56526e";
    # };

    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };




  # Configure network proxy if necessary
  networking.proxy.default = "http://127.0.0.1:20171/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  security = {
    sudo.wheelNeedsPassword = true;

    pam.services.swaylock = {};
  };


  services.v2raya.enable = true;
  services.cloudflare-warp.enable = true;

  # Extra Module Options
  drivers.amdgpu.enable = true;
  drivers.nvidia-prime = {
    enable = false;
    intelBusID = "";
    nvidiaBusID = "";
  };
  drivers.intel.enable = false;

  drivers.nvidia.enable = false;

  # Home Manager owns Hyprland; greetd is the only login manager.
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${config.home-manager.users.${username}.wayland.windowManager.hyprland.package}/bin/start-hyprland";
    };
  };

  # Keep credential storage and privilege prompts without the GNOME desktop.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.polkit.enable = true;
  # Expose Home Manager's portal definitions through the system profile.
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ inputs.emacs-overlay.overlay ];
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    clang-tools
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi

    # coreutils
    # binutils

    # gcc
    # gnumake

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    iftop
    pciutils # lspci
    usbutils # lsusb
  ];

  #modules.windowSystem.wayland.enable = true;
  # To use Tailscale, import ../../system/tailscale.nix above and log in with
  # `sudo tailscale up`. Client routing can then be configured declaratively:
  # services.tailscale.useRoutingFeatures = "client";
  # services.tailscale.extraSetFlags = [ "--exit-node-allow-lan-access" "--exit-node=<node>" ];

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
