# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
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
      inputs.vocalinux.nixosModules.vocalinux
      ../../system/system.nix
      ../../system/system-packages.nix
      ../../system/desktop-packages.nix
      # ../../system/window-systems
      ../../system/fonts.nix
      # ../../system/tailscale.nix
      # ../../system/virtualisation.nix
      ../../modules/amd-drivers.nix
      ../../modules/intel-drivers.nix
      ../../modules/nvidia-drivers.nix
      ../../modules/nvidia-prime-drivers.nix

      ./secrets
    ];

  boot.loader = {
    timeout = 3;

    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI isn't generated
      devices = ["nodev"];
      useOSProber = true;
      default = 2;
    };
  };
  boot.initrd.kernelModules = [];

  networking.hostName = "desktop"; # Define your hostname.
  # Flameshot 13 treats grim's physical-pixel image as logical pixels on Wayland.
  # Supply logical pixels to its private grim adapter at fractional scaling.
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlay
    (final: prev: {
      flameshot = prev.flameshot.override {
        grim = prev.writeShellScriptBin "grim" ''
          exec ${prev.grim}/bin/grim -s 1 "$@"
        '';
      };
    })
  ];
  programs.vocalinux = {
    enable = true;
    # The upstream package omits the optional Wayland overlay dependency.
    # Use its own nixpkgs so GTK and GI typelibs remain ABI-compatible.
    package = inputs.vocalinux.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [
        inputs.vocalinux.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.gtk-layer-shell
      ];
    });
  };

  # Keep large build workspaces on the spacious /home partition.
  nix.settings.build-dir = "/home/nix-build";
  systemd.tmpfiles.rules = [
    "d /home/nix-build 0700 root root -"
    # NVIDIA saves VRAM here during suspend; keep it off the root partition.
    "d /home/nvidia-vram 0700 root root -"
    # --remember takes no username argument; seed the greeter's cache.
    "f /var/cache/tuigreet/lastuser 0600 greeter greeter - ${username}"
  ];


  time.hardwareClockInLocalTime = true;

  # Styling Options
  stylix = {
    enable = true;
    image = ../../config/wallpapers/${wallpaper};

    # Keep application colors stable when switching wallpapers.
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

    polarity = "dark";
    opacity.terminal = 1.0;
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
  networking.proxy.default = "http://127.0.0.1:10808/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  networking.networkmanager.enable = true;
  # Prefer working DNS servers over the router's unreliable DHCP DNS.
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "223.5.5.5"
  ];
  security = {
    sudo.wheelNeedsPassword = false;

    pam.services.swaylock = {};
  };

  environment.localBinInPath = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  services.v2raya.enable = true;
  services.cloudflare-warp.enable = true;

  # Docker
  virtualisation.docker = {
    enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Extra Module Options
  drivers.amdgpu.enable = false;
  drivers.nvidia-prime = {
    enable = false;
    intelBusID = "";
    nvidiaBusID = "";
  };
  drivers.intel.enable = false;

  drivers.nvidia.enable = true;
  hardware.nvidia = {
    # Preserve GPU allocations across S3 sleep and restore them before clients.
    powerManagement.enable = true;
    moduleParams.nvidia.NVreg_TemporaryFilePath = "/home/nvidia-vram";
  };

  # Hyprland is managed by Home Manager; greetd only runs the login UI.
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        user = "greeter";
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.home-manager.users.${username}.wayland.windowManager.hyprland.package}/bin/start-hyprland";
      };
    };
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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
  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "uinput" ];
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
    config.cudaSupport = false;
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

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    clash-verge = {
      enable = false;
      autoStart = true;
      tunMode = true;
      serviceMode = true;
    };
  };

  # Enable the Open SSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  #modules.windowSystem.wayland.enable = true;
  # modules.tailscale = {
  #   enable = true;
  #   routingFeature = "client";
  #   autoprovision = {
  #     enable = true;
  #     cmd = "${pkgs.tailscale}/bin/tailscale up";
  #     # options = [ "--exit-node-allow-lan-access" "--exit-node=" ];
  #   };
  # };

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
