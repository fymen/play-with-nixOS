{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail;
in
{
  imports = [
    # ../../config/i3
    # ../../config/gtk.nix
    # ../../config/dunst.nix

    ../../config/hyprland.nix
    ../../config/waybar.nix
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
    #    ../../config/gnupg.nix
    # ../../config/bitwarden.nix
    ../../config/password-store.nix
    ../../config/misc.nix
  ];


  stylix.targets.rofi.enable = false;

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
  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
    recursive = true;
  };
  home.file.".config/wlogout/icons" = {
    source = ../../config/wlogout;
    recursive = true;
  };
  # home.file.".face.icon".source = ../../config/face.jpg;
  # home.file.".config/face.jpg".source = ../../config/face.jpg;
  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=/home/${username}/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nix-output-monitor
    nix-tree
    nil
    nix-index
    nix-prefetch-git
    nix-prefetch-scripts

    mesa

    du-dust # Modernized "du"
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

    neofetch

    font-manager
    # Terminal
    tmux

    python311Packages.pygments

    # Image viewer
    feh
    eog
    # Editor

    # Shells
    oh-my-zsh

    # Data visualization
    gnuplot
    mpv
    yt-dlp
    ripgrep
    silver-searcher

    multimarkdown
    graphviz

    gimp
    imagemagick

    gdb

    evince
    zathura

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

    # youtube-music
    ani-cli # Watch animation from cli
    rnnoise-plugin

    # Download
    deluge
    qrencode
    calibre
    #    zoom-us
    #    discord
    telegram-desktop
    #    spotify
    nautilus

    appimage-run

    # tor-browser

    # easyeffects

    alejandra
    statix

    # electrum

    # Diagram Editor
    dia
    # obs-studio                  # Recorder and streaming

    #    vmware-workstation

    opencc

    kitty
    v2rayn
  ];

  services.ssh-agent.enable = true;
  services.udiskie = {
    enable = false;
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
      extraConfig = ''
        Host racknerd
          HostName 23.95.85.103
          Port 22
      '';
    };
  };

  xdg.mimeApps = {
    enable = true;

    associations.added = {
      "image/png" = "feh.desktop";
    };

    defaultApplications = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
      "text/html" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/vnd.mozilla.xul+xml" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "default-web-browser" = "firefox.desktop";
      "default-url-scheme-handler" = "firefox.desktop";
      "scheme-handler/http" = "firefox.desktop";
      "scheme-handler/https" = "firefox.desktop";
      "default-url-scheme-handler/http" = "firefox.desktop";
      "default-url-scheme-handler/https" = "firefox.desktop";

      "x-scheme-handler/magnet" = "deluge.desktop";

      "image/png" = "org.gnome.eog.desktop";

      "video/x-matroska" = "mpv.desktop";
      "x-scheme-handler/tg" = "userapp-Telegram Desktop-FHZGI2.desktop";
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      # for flypy chinese input method
      fcitx5-rime
      # needed enable rime using configtool after installed
      fcitx5-configtool
      fcitx5-chinese-addons
      # fcitx5-mozc    # japanese input method
      fcitx5-gtk # gtk im module
    ];
  };

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

    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";

  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 10;
        hide_cursor = true;
        no_fade_in = false;
      };
      # background = [
      #   {
      #     path = "/home/${username}/Pictures/Wallpapers/city-view.jpeg";
      #     blur_passes = 3;
      #     blur_size = 8;
      #   }
      # ];
      image = [
        {
          path = "/home/${username}/Pictures/Wallpapers/sylvanas_1500x2070.jpeg";
          size = 150;
          border_size = 4;
          border_color = "rgb(0C96F9)";
          rounding = -1; # Negative means circle
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
      # input-field = [
      #   {
      #     size = "200, 50";
      #     position = "0, -80";
      #     monitor = "";
      #     dots_center = true;
      #     fade_on_empty = false;
      #     font_color = "rgb(CFE6F4)";
      #     inner_color = "rgb(657DC2)";
      #     outer_color = "rgb(0D0E15)";
      #     outline_thickness = 5;
      #     placeholder_text = "Password...";
      #     shadow_passes = 2;
      #   }
      # ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}