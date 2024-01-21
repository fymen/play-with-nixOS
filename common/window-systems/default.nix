{pkgs, config, windowSystem, ...}: {
  imports = [
    (
      if windowSystem == "wayland" then ./wayland.nix
      else if windowSystem == "xorg" then ./xorg.nix
      else throw "Unknown window system '${windowSystem}' for graphical"
    )
  ];

  config.modules.windowSystem."${windowSystem}".enable = true;
}
