# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, system, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common/system.nix
      ../../common/system-packages.nix

      ./secrets
    ] ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd-pstate
      common-gpu-amd
      common-pc-ssd
      asus-battery
    ]);

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  boot.loader = {
    timeout = 2;

    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI isn't generated
      devices = [ "nodev" ];
      useOSProber = true;
    };
  };
  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";

    # Configure AMD graphics
    videoDrivers = [ "amdgpu" ];

    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "oscar";

      defaultSession = "hyprland";

      gdm = {
        enable = true;
        wayland = true;
      };

      lightdm = {
        enable = false;
        greeters.enso = {
          enable = true;
        };
      };
      # Enable automatic login for the user.
    };

    desktopManager.gnome.enable = false;
    ## Configurations for I3
    dpi = 234;
    upscaleDefaultCursor = true;
    windowManager= {
      i3 = {
        enable = false;
        extraPackages = with pkgs; [
          j4-dmenu-desktop
          i3lock
          i3blocks
        ];
      };
    };

  };

  security= {
    sudo.wheelNeedsPassword = false;

    pam.services.swaylock = {};
  };

  programs.hyprland.enable = true;

  # bigger tty fonts
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GDK_SCALE = "1.2";
    GDK_DPI_SCALE = "1.2";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";

    NIXOS_OZONE_WL = "1"; # Wayland support in Chromium and Electron based applications
    MOZ_USE_XINPUT2 = "1";
    MANGOHUD = "1"; # Enable for all Vulkan games

  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    # Load AMD CPU microcode
    cpu.amd.updateMicrocode = true;
    # AMD GPU Configuration
    amdgpu = {
      amdvlk = true;
      opencl = true;
    };

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        libva-utils
        libGL
        rocmPackages.clr.icd
      ];
      setLdLibraryPath = true;
    };
    # Battery
    asus.battery.chargeUpto = 85;
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
  };

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.oscar = {
    isNormalUser = true;
    description = "oscar";
    # linger = true;              # Start user services before login
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      #  thunderbird
    ];
  };

  # # Game
  # programs.gamescope.enable = true;
  # programs.steam = {
  #   enable = true;
  #   gamescopeSession.enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };
  # hardware.steam-hardware.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    inconsolata
    wqy_zenhei
    wqy_microhei
    open-sans

    times-newer-roman
    font-awesome
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nix-index
    nix-prefetch-git
    nix-prefetch-scripts

    mesa
    brightnessctl
    acpi
    man-pages

    coreutils
    binutils
    pass

    gcc
    gnumake

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


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  # List services that you want to enable:

  # virtualisation.vmware.host.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
