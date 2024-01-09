{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
  ];

  xdg.configFile = {
    "waybar/config" .source = ./config;
    "waybar/style.css" .source = ./style.css;
  };
}
