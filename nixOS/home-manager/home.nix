{ config, pkgs, ... }:

let
  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
    lxml # for eaf
    qrcode # eaf-file-browser
    pysocks # eaf-browser
    pymupdf # eaf-pdf-viewer
    pypinyin # eaf-file-manager
    psutil # eaf-system-monitor
    retry # eaf-markdown-previewer
    markdown

    pygments
    python
    venvShellHook
    numpy
    pandas
    opencv4
    matplotlib
    pyqt6
    pyqt6-sip
    pyqt6-webengine
    epc
    sexpdata
    browser-cookie3
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;

  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full
      dvisvgm dvipng # for preview and export as html
      wrapfig amsmath ulem hyperref capt-of minted;
  });
in

{
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xorg.xev                    # get key code
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science es]))
    zsh
    gcc
    gnumake
    cmake
    file
    tree
    xclip
    unzip
    gnupg
    ripgrep
    silver-searcher

    # Terminal
    tmux
    alacritty

    python-with-my-packages
    # Image viewer
    feh
    flameshot
    # Editor
    emacs29
    # Shells
    oh-my-zsh
    j4-dmenu-desktop
    # Browsers
    firefox
    chromium
    # Data visualization
    gnuplot
    # Player
    mplayer
    mpv


    multimarkdown
    graphviz

    yt-dlp

    gimp
    imagemagick

    gdb

    evince
    libreoffice
    # Sound volume control
    pavucontrol

    networkmanager

    tex

    # Download
    qbittorrent
    # Password Manager
    bitwarden
    zoom-us


    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".tmux.conf" .source = dotfiles/tmux.conf;
    ".config/i3/config" .source = dotfiles/i3/config;
    ".config/i3blocks/config" = {
      text = ''
      [battery]
      command=acpi| tr -d ',' | awk '{print $3, $4}'
      interval=60

      [time_date]
      command=date +" %a %d %b - %H:%M:%S"
      interval=1
      '';
    };
    ".tmux.conf" = {
      text = ''
      set -g prefix C-l
      set-window-option -g mode-keys vi
      set -g status-bg black
      set -g status-fg white
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ',screen-256color:Tc'
      '';
    };
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # "org/roam" = {
    #   source = builtins.fetchGit {
    #     url = "ssh://git@github.com/fymen/roaming.git";
    #     ref = "master";
    #     rev = "8a10ae2faf15d564c9ed0cf9b9a9d65d27356cd9";
    #   };
    # recursive = true;
    # };

    # ".emacs.d" = {
    #   source = pkgs.fetchFromGitHub {
    #     owner = "fymen";
    #     repo = ".emacs.d";
    #     rev = "410a958";
    #     sha256 = "sha256-jEvDbukPuF31zVWy+PnduPp0Lb7tZY4UaFiL09HPA94=";
    #   };
    #   recursive = true;
    # };
  };

  programs = {
    git = {
      enable = true;
      userName = "Oscar Qi";
      userEmail = "fengmao.qi@gmail.com";
    };
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "af-magic";
      };
    };
  };

  imports = [
    ./apps/alacritty.nix
  ];


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
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
