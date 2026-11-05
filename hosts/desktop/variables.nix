{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Fengmao Qi";
  gitEmail = "fengmao.qi@gmail.com";

  # Hyprland Settings
  extraMonitorSettings = ''
    -- Match the display rather than a connector that can change after reconnecting.
    -- Native 4K at 150% gives a 2560x1440 logical workspace.
    hl.monitor({ output = "desc:Samsung Electric Company Odyssey G7 HNBX501702", mode = "3840x2160@165", position = "0x0", scale = 1.5 })
  '';

  # Waybar Settings
  clock24h = true;

  wallpaper = "naraka.jpeg";

  # Program Options
  browser = "firefox"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty -e tmux"; # Set Default System Terminal
  keyboardLayout = "us";
}
