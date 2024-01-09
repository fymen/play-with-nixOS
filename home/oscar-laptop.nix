{ config, pkgs, ... }:

{
  imports = [
    ./wayland
    ./apps
  ];

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
      inherit (pkgs.texlive) scheme-full
        dvisvgm dvipng # for preview and export as html
        wrapfig amsmath ulem hyperref capt-of minted;
    })

    # youtube-music
    ani-cli                     # Watch animation from cli
    rnnoise-plugin

    # Download
    transmission_4-gtk
    # rtorrent
    aria

    # Password Manager
    bitwarden

    calibre
    zoom-us
    discord
    telegram-desktop

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

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };

  modules.editors = {
    emacs.enable = true;
    emacs.personal.enable = true;
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
