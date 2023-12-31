{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi-wayland
    waybar
    hyprpaper
  ];

  home.file = {
    ".config/hypr/hyprland.conf" .source = ./hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf" .source = ./hypr/hyprpaper.conf;
    ".config/waybar/config" .source = ./waybar/config;
    ".config/waybar/style.css" .source = ./waybar/style.css;
    ".config/rofi/config.rasi" .source = ./rofi/config.rasi;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    __GL_VRR_ALLOWED="1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    };
}
