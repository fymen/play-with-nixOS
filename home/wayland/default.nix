{ config, pkgs, ... }:

{
  imports = [
    ./hyprland
    ./waybar
    ./pypr
    ./tofi
  ];

  home.packages = with pkgs; [
    xdg-desktop-portal-hyprland
    grim
    slurp
    wl-clipboard
    polkit_gnome
    wlogout

    xwaylandvideobridge         # Share desktop of X on wayland.
    wf-recorder
    wlr-randr
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
  ];

  home.sessionVariables = {
    __GL_VRR_ALLOWED="1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";

    NIXOS_OZONE_WL = "1";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";

    QT_WAYLAND_DISABLE_WINDOWDECORATION = "2";
    QT_AUTO_SCREEN_SCALE_FACTOR = "2";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };
}
