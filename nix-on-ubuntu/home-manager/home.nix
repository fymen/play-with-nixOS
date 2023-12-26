{ config, pkgs, ... }:

{
  home.username = "oscar";
  home.homeDirectory = "/home/oscar/";
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    alacritty
    # Download
    qbittorrent
    # Password Manager
    bitwarden
    discord
    zoom-us
  ];

  home.file = {
    ".tmux.conf" .source = dotfiles/tmux.conf;
    ".config/i3/config" .source = dotfiles/i3/config;
    ".zshrc" .source = dotfiles/zshrc;
  };

  imports = [
    ./apps/alacritty.nix
  ];
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
}
