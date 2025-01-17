{pkgs, ...}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    man-pages
    vim

    wget
    curl
    # rtorrent

    git

    jq

    file
    tree

    unzip
    zip
    xz
    p7zip

    unrar

    gnumake

    lf                          # file manager

    ntfs3g

    v2rayn
  ];
}
