{ pkgs, ... }:

{
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
    unzip
    zip
    xz
    p7zip
    gnupg

    gnumake
  ];
}
