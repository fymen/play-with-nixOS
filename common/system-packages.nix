{pkgs, ...}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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

    gnumake

    lf                          # file manager
  ];
}
