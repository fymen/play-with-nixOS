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

    xwaylandvideobridge         # Share desktop of X on wayland.
    wf-recorder
    wlr-randr
    libsForQt5.qt5.qtwayland
    qt6.qtwayland

    wlsunset
    swaylock-effects
  ];

  services.wlsunset = {
    enable = true;
    package = pkgs.wlsunset;
    latitude = "43.6";
    longitude = "-79.3";
  };

  programs.wlogout = {
    enable = true;
    package = pkgs.wlogout;
    # layout = [  {    label = "shutdown";    action = "systemctl poweroff";    text = "Shutdown";    keybind = "s";  }];

  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      ring-color = "bb00cc";
      key-hl-color = "880033";
      line-color = "00000000";
      inside-color = "00000088";
      separator-color = "00000000";
      grace = 2;
      fade-in = 0.2;
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
      { timeout = 180; command = "${pkgs.swaylock}/bin/swaylock"; }
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
