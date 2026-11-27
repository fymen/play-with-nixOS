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
      ../../system/system.nix
      ../../system/system-packages.nix
      ../../system/desktop-packages.nix
      ../../system/desktop-base.nix
      # ../../system/window-systems
      ../../system/fonts.nix
      ../../system/tailscale.nix
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
      default = "saved";
    };
  };
  boot.initrd.kernelModules = [];

  networking.hostName = "desktop"; # Define your hostname.
  # Flameshot 13 treats grim's physical-pixel image as logical pixels on Wayland.
  # Supply logical pixels to its private grim adapter at fractional scaling.
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlay
    (final: prev: {
      # Mainline b12662 supports both MiniCPM-V 4.7 and Inkling's mainline GGUF.
      llama-cpp-minicpm = (prev.llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: {
        version = "12662";
        src = prev.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          rev = "b12662";
          hash = "sha256-mYD05rUpGnSJTO1r4YAop0TjaPAqo0CuTXG3vejWF78=";
        };
        nativeBuildInputs = builtins.filter (input: (input.name or "") != "npm-config-hook") old.nativeBuildInputs;
        buildInputs = old.buildInputs ++ [ prev.cudaPackages_12.cuda_nvml_dev ];
        npmDeps = null;
        preConfigure = "";
        cmakeFlags = old.cmakeFlags ++ [
          "-DLLAMA_BUILD_WEBUI=OFF"
          "-DLLAMA_BUILD_UI=OFF"
          "-DLLAMA_BUILD_COMMIT:STRING=1f3ea67"
          "-DCMAKE_CUDA_ARCHITECTURES=89"
        ];
      });
      flameshot = prev.flameshot.override {
        grim = prev.writeShellScriptBin "grim" ''
          exec ${prev.grim}/bin/grim -s 1 "$@"
        '';
      };
    })
  ];
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-minicpm;
    settings = {
      host = "127.0.0.1";
      port = 8080;
      models-max = 1;
      models-preset = pkgs.writeText "local-models.ini" ''
        version = 1
        [*]
        ctx-size = 65536
        parallel = 1
        flash-attn = on
        cache-type-k = q4_0
        cache-type-v = q4_0
        fit = on
        fit-target = 1536
        jinja = true
        [minicpm-v-4.7-35b-a3b]
        model = /home/minicpm-models/MiniCPM-V-4_7-35B-A3B-Q4_K_M.gguf
        mmproj = /home/minicpm-models/mmproj-model-f16.gguf
        n-gpu-layers = auto
        reasoning = off
        [inkling]
        model = /home/minicpm-models/Inkling-2-Mini-UD-Q3_K_XL-mainline.gguf
        mmproj = /home/minicpm-models/mmproj-F16.gguf
        n-gpu-layers = 99
        n-cpu-moe = 12
        load-mode = none
        cache-type-k = q4_0
        cache-type-v = q4_0
        fit = off
        ubatch-size = 64
        temp = 1.0
        top-p = 1.0
        top-k = 0
        min-p = 0.0
        [qwen3.6-27b]
        model = /home/minicpm-models/Qwen3.6-27B-Q4_K_M.gguf
        mmproj = /home/minicpm-models/mmproj-Qwen3.6-27B-Q8_0.gguf
      '';
      api-key = "minicpm-local";
      no-webui = true;
    };
  };
  systemd.services.llama-cpp = lib.mkIf config.services.llama-cpp.enable {
    serviceConfig = {
      ProtectHome = lib.mkForce "read-only";
      DevicePolicy = "closed";
      DeviceAllow = [
        "char-nvidiactl"
        "char-nvidia-caps"
        "char-nvidia-frontend"
        "char-nvidia-uvm"
      ];
    };
  };
  # Keep large build workspaces on the spacious /home partition.
  nix.settings.build-dir = "/home/nix-build";
  systemd.tmpfiles.rules = [
    "d /home/minicpm-models 0755 ${username} users -"
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




  # Explicit HTTP/SOCKS forwarding only; transparent proxy stays disabled
  # in v2rayA's application settings. Keep the service itself proxy-free.
  networking.proxy.default = "http://127.0.0.1:10808/";
  networking.proxy.noProxy = "127.0.0.1,localhost,::1,internal.domain,130.162.149.210";
  # Prefer working DNS servers over the router's unreliable DHCP DNS.
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "223.5.5.5"
  ];
  security = {
    sudo.wheelNeedsPassword = false;

    pam.services.swaylock = {};
  };

  services.v2raya = {
    enable = false;
    # The existing SQLite state requires the newer server and matching core.
    package = pkgs.callPackage ../../packages/v2raya.nix { };
  };
  systemd.services.v2raya = {
    environment = {
      V2RAYA_ADDRESS = "127.0.0.1:2017";
      V2RAYA_CONFIG = "/etc/v2raya";
      V2RAYA_NFTABLES_SUPPORT = "off";
    };
    # Do not let the root proxy service inherit a proxy pointing at itself.
    serviceConfig.UnsetEnvironment = [
      "http_proxy" "https_proxy" "all_proxy" "ftp_proxy"
      "HTTP_PROXY" "HTTPS_PROXY" "ALL_PROXY" "FTP_PROXY"
    ];
  };
  services.cloudflare-warp.enable = false;


  # Docker
  # Desktop services can start while NetworkManager connects in the background.
  systemd.services.NetworkManager-wait-online.enable = false;
  services.udisks2.enable = true;
  virtualisation.docker = {
    enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

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
  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;

    polkit.enable = true;
  };

  services.gnome.at-spi2-core.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "hyprland" "gtk" ];
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      "org.freedesktop.impl.portal.Inhibit" = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    linger = true;
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

  # Join the tailnet interactively with `tailscale up --accept-dns=false`.
  # Keep local DNS/proxy behavior; selecting an exit node remains opt-in.
  services.tailscale = {
    useRoutingFeatures = "client";
    extraSetFlags = [ "--operator=${username}" "--accept-dns=false" ];
  };

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
