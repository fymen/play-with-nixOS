{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
  ];

  home.file = {
    ".config/waybar/config" .source = ./config;
    ".config/waybar/style.css" .source = ./style.css;
  };
}
