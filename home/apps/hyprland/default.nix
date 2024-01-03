{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # rofi-wayland
    tofi
    waybar
    hyprpaper
    xdg-desktop-portal-hyprland
    grim
    slurp
    wl-clipboard
    polkit_gnome
  ];

  home.file = {
    ".config/hypr/hyprland.conf" .source = ./hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf" .source = ./hypr/hyprpaper.conf;
    ".config/waybar/config" .source = ./waybar/config;
    ".config/waybar/style.css" .source = ./waybar/style.css;
    # ".config/rofi/config.rasi" .source = ./rofi/config.rasi;
    ".config/tofi/config" = {
      text = ''
      anchor = top
      width = 50%
      height = 32
      horizontal = true
      font-size = 20
      hint-font = true
      prompt-text = ""
      font = monospace
      outline-width = 0
      border-width = 0
      text-color = #D0BF8F
      background-color = #0008
      selection-color = #DFAF8F
      min-input-width = 50
      result-spacing = 15
      padding-top = 0
      padding-bottom = 0
      padding-left = 0
      padding-right = 0
      '';
    };
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
    NIXOS_OZONE_WL = "1";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";

    QT_WAYLAND_DISABLE_WINDOWDECORATION = "2";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "2";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };
}
