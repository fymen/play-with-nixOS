{pkgs, ...}: {
  programs.waybar = {
    enable = true;
  };

  xdg.configFile = {
    "waybar/config" .source = ./config;
    "waybar/style.css" .source = ./style.css;
  };
}
