{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    inconsolata
    wqy_zenhei
    wqy_microhei
    open-sans
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git

    zsh
    file
    tree
    killall
    xclip
    unzip
    zip
    xz
    p7zip
    gnupg

  ];
}
