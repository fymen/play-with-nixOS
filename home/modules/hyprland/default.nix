{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.windowManager.hyprland;
in {
  imports = [
    ./hyprland
    ./waybar
    ./tofi
    # ./rofi
    ./waylockout
    ./wlogout
    ./foot.nix
  ];

  options.modules.windowManager.hyprland.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Enable hyprland configuration.
    '';
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wev
      xdg-desktop-portal-hyprland
      grim
      slurp
      wl-clipboard
      polkit_gnome

      xwaylandvideobridge # Share desktop of X on wayland.
      wf-recorder
      wlr-randr
      libsForQt5.qt5.qtwayland
      qt6.qtwayland

      wlsunset
    ];

    services.wlsunset = {
      enable = true;
      package = pkgs.wlsunset;
      latitude = "43.6";
      longitude = "-79.3";
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "lock";
          command = "${pkgs.swaylock-effects}/bin/swaylock";
        }
        {
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock";
        }
      ];
      timeouts = [
        {
          timeout = 180;
          command = "${pkgs.swaylock-effects}/bin/swaylock";
        }
      ];
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        Unit = {
          Description = "polkit-gnome-authentication-agent-1";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    programs.chromium.commandLineArgs = [
      "--gtk-version=4"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
    ];
    programs.firefox.package = pkgs.firefox-wayland;

    home.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      WLR_RENDERER = "vulkan";

      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";

      MOZ_ENABLE_WAYLAND = 1; # Firefox Wayland
      MOZ_DBUS_REMOTE = 1; # Firefox wayland
      GDK_BACKEND = "wayland";

      NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland

      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      #NIXOS_XDG_OPEN_USE_PORTAL = "0";
      XDG_SESSION_TYPE = "wayland";

      GTK_USE_PORTAL = "1";

      CLUTTER_BACKEND = "wayland";

      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      BROWSER = "${pkgs.firefox}/bin/firefox";

      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };
}
