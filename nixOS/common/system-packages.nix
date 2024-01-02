{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    inconsolata
    wqy_zenhei
    wqy_microhei
    open-sans
    emacs-all-the-icons-fonts
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

    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science es]))
    man-pages
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
    ripgrep
    silver-searcher

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
