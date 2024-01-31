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
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      WLR_RENDERER = "vulkan";

      GDK_SCALE = "2";
      GDK_DPI_SCALE = "1.5";

      MOZ_ENABLE_WAYLAND = "1"; # Firefox Wayland
      MOZ_DBUS_REMOTE = "1"; # Firefox wayland
      GDK_BACKEND = "wayland";

      NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland

      _JAVA_AWT_WM_NONREPARENTING = "1";

      #NIXOS_XDG_OPEN_USE_PORTAL = "0";
      XDG_SESSION_TYPE = "wayland";

      GTK_USE_PORTAL = "1";

      CLUTTER_BACKEND = "wayland";

      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };
}
