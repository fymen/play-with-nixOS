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


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  imports = [
    ../common/home-packages.nix

#    ./apps/i3
    ./apps/hyprland
    ./apps/tmux.nix
    ./apps/zsh.nix
    ./apps/git.nix
    ./apps/alacritty.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-full
        dvisvgm dvipng # for preview and export as html
        wrapfig amsmath ulem hyperref capt-of minted;
    })

    # Download
    transmission_4-gtk

    # Password Manager
    bitwarden

    calibre
    zoom-us
    discord

    # Wayland
    wlr-randr
    libsForQt5.qt5.qtwayland
    qt6.qtwayland

    # lutris
    #    vmware-workstation

  ];

  services.dunst = {
    enable = true;
    settings = {
      global = {
        browser = "${config.programs.firefox.package}/bin/firefox -new-tab";
        dmenu = "${pkgs.rofi}/bin/tofi-drun | xargs hyprctl dispatch exec --";
        follow = "mouse";
        font = "DejaVu Sans Mono 20";
        format = "<b>%s</b>\\n%b";
        frame_color = "#555555";
        frame_width = 2;
        geometry = "500x5-5+30";
        horizontal_padding = 8;
        icon_position = "off";
        line_height = 0;
        markup = "full";
        padding = 8;
        separator_color = "frame";
        separator_height = 2;
        transparency = 10;
        word_wrap = true;
      };

      urgency_low = {
        background = "#1d1f21";
        foreground = "#4da1af";
        frame_color = "#4da1af";
        timeout = 10;
      };

      urgency_normal = {
        background = "#1d1f21";
        foreground = "#70a040";
        frame_color = "#70a040";
        timeout = 15;
      };

      urgency_critical = {
        background = "#1d1f21";
        foreground = "#dd5633";
        frame_color = "#dd5633";
        timeout = 0;
      };

      # shortcuts = {
    #   context = "mod4+grave";
    #   close = "mod4+shift+space";
    #   };
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
      EDITOR = "vim";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  }
