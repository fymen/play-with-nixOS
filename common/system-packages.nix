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
    nix-index
    nix-prefetch-git
    nix-prefetch-scripts

    coreutils
    binutils
    pass
    vim
    wget
    curl
    git

    brightnessctl
    acpi

    man-pages
    direnv
    zsh
    gcc
    gnumake
    cmake
    file
    tree
    killall
    xclip
    unzip
    zip
    xz
    p7zip
    gnupg

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
