{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Fengmao Qi";
  gitEmail = "fengmao.qi@gmail.com";

  # Hyprland Settings
  extraMonitorSettings = ''
    hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = 1.5 })
  '';

  # Waybar Settings
  clock24h = true;

  wallpaper = "naraka.jpeg";

  # Program Options
  browser = "firefox"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty -e tmux"; # Set Default System Terminal
  keyboardLayout = "us";
}
