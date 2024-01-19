{pkgs, config, windowSystem, ...}: {
  imports = [
    ./wayland.nix
    ./xorg.nix
  ];

  config.modules.windowSystem."${windowSystem}".enable = true;


  config.environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GDK_SCALE = "1.2";
    GDK_DPI_SCALE = "1.2";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";

    MOZ_USE_XINPUT2 = "1";
    MANGOHUD = "1"; # Enable for all Vulkan games
  };
}
