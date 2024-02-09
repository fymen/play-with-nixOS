{pkgs, flake, config, ...}:

{
  imports = [
    ./wayland.nix
    ./xorg.nix
  ];
}
