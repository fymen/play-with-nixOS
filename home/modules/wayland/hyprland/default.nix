{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = (builtins.readFile ./hyprland.conf);
  };

  home.packages = with pkgs; [
    hyprpaper
    pyprland
  ];

  xdg.configFile = {
    # "hypr/hyprland.conf" .source = ./hyprland.conf;
    "hypr/hyprpaper.conf" .source = ./hyprpaper.conf;
    "hypr/pyprland.toml" .source = ./pyprland.toml;
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}