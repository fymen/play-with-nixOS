{ config, pkgs, ... }:

{
  imports = [
    ./hyprland
    ./waybar
    ./tofi
  ];

  home.packages = with pkgs; [
    wev
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

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };


  services.swayidle = {
    enable = true;
    events = [
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock"; }
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock"; }
    ];
    timeouts = [
      { timeout = 60; command = "${pkgs.swaylock}/bin/swaylock"; }
    ];
  };

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
}
