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

    # For wayland only
    programs.chromium.commandLineArgs = [
      "--gtk-version=4"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
    ];
    programs.firefox.package = pkgs.firefox-wayland;

    home.sessionVariables = {
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
      BROWSER = "${pkgs.firefox}/bin/firefox";
    };
  };
}
