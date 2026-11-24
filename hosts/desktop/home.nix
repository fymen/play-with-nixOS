{
  config,
  lib,
  osConfig,
  pkgs,
  inputs,
  username,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail;
  zlibCli = pkgs.callPackage ../../packages/zlib-cli.nix { };
  computerUseLinux = pkgs.callPackage ../../packages/computer-use-linux.nix { };

in
{
  imports = [
    ../../config/hermes.nix
    ../../config/daily-report.nix
    ../../config/voxtype.nix
    inputs.omp.homeManagerModules.default
    # ../../config/i3
    # ../../config/gtk.nix
    # ../../config/dunst.nix

    ../../config/hyprland.nix
    ../../config/waybar.nix
    ../../config/swaync.nix
    ../../config/rofi.nix
    ../../config/wlogout.nix

    ../../config/emacs

    ../../config/tmux.nix
    ../../config/zsh.nix
    ../../config/git.nix
    #    ../../config/terminals

    ../../config/firefox.nix
    ../../config/chromium.nix
    ../../config/mpv.nix
    # ../../config/zathura.nix
    ../../config/gnupg.nix
    # ../../config/bitwarden.nix
    ../../config/password-store.nix
    ../../config/fcitx.nix
    ../../config/misc.nix
    ../../config/openclaw.nix
  ];

  dconf.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      toolkit-accessibility = true;
    };
  };

  programs.omp.enable = true;

  stylix.targets.rofi.enable = false;
  stylix.targets.swaync.enable = false;
  stylix.targets.emacs.enable = false;
  stylix.targets.fcitx5.enable = false;
  stylix.targets.firefox.profileNames = [ "${username}" ];
  stylix.targets.qt.platform = "qtct";
  # NixOS owns the portal services and backend registration on this host.
  xdg.portal.enable = lib.mkForce false;
  home.sessionVariables.NIX_XDG_DESKTOP_PORTAL_DIR = "/run/current-system/sw/share/xdg-desktop-portal/portals";
  systemd.user.sessionVariables.NIX_XDG_DESKTOP_PORTAL_DIR = "/run/current-system/sw/share/xdg-desktop-portal/portals";

  # Both local models use the same llama.cpp router.
  # Keep Pi's settings/auth files writable and preserve the default cloud model.
  home.file.".pi/agent/models.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/models.schema.json";
    providers.local-llama = {
      name = "Local llama.cpp";
      baseUrl = "http://127.0.0.1:8080/v1";
      api = "openai-completions";
      # Local-only service credential, shared with services.llama-cpp.
      apiKey = "minicpm-local";
      authHeader = true;
      models = [
        {
          id = "minicpm-v-4.7-35b-a3b";
          name = "MiniCPM-V 4.7 35B-A3B (local)";
          reasoning = false;
          input = [ "text" "image" ];
          contextWindow = 65536;
          maxTokens = 8192;
          cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
          compat = {
            supportsStore = false;
            supportsDeveloperRole = false;
            supportsReasoningEffort = false;
            maxTokensField = "max_tokens";
          };
        }
        {
          id = "inkling";
          name = "inkling(local)";
          reasoning = false;
          input = [ "text" "image" ];
          contextWindow = 65536;
          maxTokens = 8192;
          cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
          compat = {
            supportsStore = false;
            supportsDeveloperRole = false;
            supportsReasoningEffort = false;
            maxTokensField = "max_tokens";
          };
        }

      ];

    };

  };


  # Supply a complete icon theme for GTK trays and application launchers.
  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # Place Files Inside Home Directory
  # home.file.".face.icon".source = ../../config/face.jpg;
  # home.file.".config/face.jpg".source = ../../config/face.jpg;

  # Keep a declarative CLI entry available for narrowly scoped local deployment.
  home.file.".local/bin/zlib".source = lib.getExe zlibCli;
  home.file.".local/bin/computer-use-linux".source = lib.getExe computerUseLinux;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    computerUseLinux
    zlibCli
    nix-output-monitor
    nix-tree
    nil
    nix-index
    nix-prefetch-git
    nix-prefetch-scripts

    mesa

    dust # Modernized "du"
    bat # Alternative to "cat"
    btop # Alternative to "top"
    nvtopPackages.nvidia # Monitor GPU process
    starship
    fd # Alternative to "find"
    lazygit # Magit alternative
    glow # Markdown viewer in command line

    xdg-utils

    grc # Colorize command output

    ydotool # Desktop automation tool, move mouse or something
    autojump # Jump around directories fastly

    hyfetch

    font-manager
    # Terminal
    tmux

    # python311Packages.pygments

    # Python development tools and commonly used libraries.
    (python3.withPackages (ps: [
      ps.pip
      ps.virtualenv
      ps.ipython
      ps.requests
      ps.numpy
      ps.pandas
      ps.pillow
      ps.pytest
    ]))

    # Image viewer
    eog
    # Editor
    cc-switch # Manage AI coding agent configurations

    # Data visualization
    gnuplot
    mpv
    ffmpeg
    nodejs_24 # Node.js and npm for Remotion/TypeScript projects
    whisper-cpp # Provides whisper-cli for local speech transcription
    yt-dlp
    ripgrep

    multimarkdown
    graphviz

    gimp
    (blender.override { cudaSupport = true; })
    imagemagick
    tesseract

    gdb

    evince

    libreoffice
    # Sound volume control
    pavucontrol

    networkmanager

    # nix-alien
    gcc
    cmake
    libtool
    #    clang-tools_15

    parallel

    # Download
    qrencode
    calibre
    #    zoom-us
    #    discord
    telegram-desktop
    #    spotify
    nautilus

    poppler-utils

    # appimage-run

    # tor-browser
    tsukimi
    v2rayn

    cloudflare-warp             # https://developers.cloudflare.com/warp-client/get-started/linux/
    owl
    # easyeffects

    net-tools

    alejandra
    statix

    # electrum

    # obs-studio                  # Recorder and streaming

    #    vmware-workstation

    opencc

    kitty

    wl-clipboard
    cliphist
    pinta
    flameshot

    hugo
    localsend

    inkscape
  ];

  services.ssh-agent.enable = true;
  services.udiskie = {
    enable = true;
    automount = true;
    tray = "always";
  };

  modules = {
    editors = {
      emacs.enable = true;
      emacs.personal.enable = false;
      emacs.service.enable = false;
    };

    misc.enable = true;
  };

  programs = {
    # Easy shell environments
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    # Replacement for ls
    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "vps" = {
          hostname = "47.79.20.252";
          port = 22;
        };
      };
    };
  };

  # xdg.mimeApps = {
  #   enable = true;

  #   associations.added = {
  #     "image/png" = "feh.desktop";
  #   };

  #   defaultApplications = {
  #     "application/pdf" = ["org.gnome.Evince.desktop"];
  #     "text/html" = "firefox.desktop";
  #     "application/xhtml+xml" = "firefox.desktop";
  #     "application/vnd.mozilla.xul+xml" = "firefox.desktop";
  #     "x-scheme-handler/http" = "firefox.desktop";
  #     "x-scheme-handler/https" = "firefox.desktop";
  #     "x-scheme-handler/about" = "firefox.desktop";
  #     "x-scheme-handler/unknown" = "firefox.desktop";
  #     "default-web-browser" = "firefox.desktop";
  #     "default-url-scheme-handler" = "firefox.desktop";
  #     "scheme-handler/http" = "firefox.desktop";
  #     "scheme-handler/https" = "firefox.desktop";
  #     "default-url-scheme-handler/http" = "firefox.desktop";
  #     "default-url-scheme-handler/https" = "firefox.desktop";

  #     "x-scheme-handler/magnet" = "deluge.desktop";

  #     "image/png" = "org.gnome.eog.desktop";

  #     "video/x-matroska" = "mpv.desktop";
  #     "x-scheme-handler/tg" = "userapp-Telegram Desktop-FHZGI2.desktop";
  #   };
  # };


  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/oscar/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "${pkgs.vim}/bin/vim";
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
  };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
