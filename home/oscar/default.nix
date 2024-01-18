{ inputs, system, config, pkgs, ... }:

{
  imports = [
    ../modules
  ];

  # colorschemetest = inputs.nix-colors.colorSchemes.gruvbox-light-soft;
  colorscheme = inputs.nix-colors.lib.schemeFromYAML "catppuccin-macchiato" (builtins.readFile ../../common/color-themes/catppuccin-macchiato.yaml);
  colorschemetest = inputs.nix-colors.lib.schemeFromYAML "alect-light" (builtins.readFile ../../common/color-themes/alect-light.yaml);

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "oscar";
  home.homeDirectory = "/home/oscar";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-medium
        dvisvgm dvipng # for preview and export as html
        wrapfig amsmath ulem hyperref capt-of minted;
    })

    nix-output-monitor
    nix-tree
    # nix-alien

    parallel

    xclip

    # youtube-music
    ani-cli                     # Watch animation from cli
    rnnoise-plugin


    # Download
    deluge

    qrencode

    calibre
    zoom-us
    discord
    telegram-desktop

    spotify

    gnome.nautilus

    appimage-run

    tor-browser

    easyeffects
    # obs-studio                  # Recorder and streaming

    #    vmware-workstation

    # Gaming
    # mangohud
    # lutris
    # heroic
    # wineWowPackages.stable
    # # wineWowPackages.waylandFull # unstable
    # winetricks
    # protonup-qt
    # protontricks
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
      emacs.personal.enable = true;
      emacs.service.enable = true;
    };

    misc.enable = true;
  };

  programs = {
    # Easy shell environments
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Replacement for ls
    eza = {
      enable = true;
      enableAliases = true;
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
      "x-scheme-handler/magnet" = "userapp-transmission-gtk-SWL1G2.desktop";
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

      "x-scheme-handler/magnet" = "userapp-transmission-gtk-SWL1G2.desktop";

      "video/x-matroska" = "mpv.desktop";

    };
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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
