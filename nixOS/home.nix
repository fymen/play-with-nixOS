{ config, pkgs, ... }:

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
    # Fonts
    inconsolata
    # Terminal
    tmux
    alacritty

    git
    wget
    # Image viewer
    feh
    gnome.eog
    flameshot
    # Editor
    vim
    emacs29
    # Shells
    zsh
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
    # Program
    opencv4
    # Download
    qbittorrent
    # Password Manager
    bitwarden

    multimarkdown
    graphviz

    unzip
    gnupg
    ripgrep
    yt-dlp

    gimp
    imagemagick
    gdb

    libreoffice
    coreutils
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
    ".tmux.conf" .source = dotfiles/tmux.conf;
    ".config/i3/config" .source = dotfiles/i3/config;
    ".zshrc" .source = dotfiles/zshrc;
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
    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 15.0;
        };
        colors = {
          primary = {
            background = "#1D1F21";
            foreground = "#C5C8C6";
          };
        };
      };
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
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}