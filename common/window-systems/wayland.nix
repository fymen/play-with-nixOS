{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.windowSystem.wayland;
in {
  options.modules.windowSystem.wayland = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable wayland window system.
      '';
    };
  };

  config = mkIf cfg.enable {
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

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Wayland support in Chromium and Electron based applications
    };
  };
}
