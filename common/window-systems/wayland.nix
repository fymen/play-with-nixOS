{ config, pkgs, inputs, system, lib, ... }:

{
  services = {
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = "oscar";
        };
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd ${pkgs.hyprland}/bin/Hyprland";
          user = "oscar";
        };
      };
    };

    udisks2.enable = true;
  };

  programs.hyprland.enable = true;

  environment.variables = {
    NIXOS_OZONE_WL = "1"; # Wayland support in Chromium and Electron based applications
  };

}
