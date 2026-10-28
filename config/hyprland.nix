{
  pkgs,
  username,
  host,
  ...
}:

let
  inherit (import ../hosts/${host}/variables.nix)
    browser
    terminal
    extraMonitorSettings
    keyboardLayout
    wallpaper
  ;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "lua";
    extraConfig = ''
      hl.env("NIXOS_OZONE_WL", "1")
      hl.env("NIXPKGS_ALLOW_UNFREE", "1")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")
      hl.env("GDK_BACKEND", "wayland, x11")
      hl.env("CLUTTER_BACKEND", "wayland")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")
      hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
      hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
      hl.env("SDL_VIDEODRIVER", "x11")
      hl.env("MOZ_ENABLE_WAYLAND", "1")

      hl.on("hyprland.start", function()
        hl.exec_cmd("dbus-update-activation-environment --systemd --all")
        hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("killall -q swww;sleep .5 && swww init")
        hl.exec_cmd("killall -q waybar;sleep .5 && waybar")
        hl.exec_cmd("killall -q swaync;sleep .5 && swaync")
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("lxqt-policykit-agent")
        hl.exec_cmd("wl-paste --type text --watch cliphist store")
        hl.exec_cmd("wl-paste --type image --watch cliphist store")
        hl.exec_cmd("sleep 1.5 && swww img /home/${username}/Pictures/Wallpapers/${wallpaper}")
      end)

      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
      ${extraMonitorSettings}

      hl.config({
        general = {
          gaps_in = 6,
          gaps_out = 8,
          border_size = 2,
          layout = "dwindle",
          resize_on_border = true,
        },
        input = {
          kb_layout = "${keyboardLayout}",
          kb_options = "caps:super",
          follow_mouse = 1,
          touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            scroll_factor = 0.8,
          },
          sensitivity = 0,
          accel_profile = "flat",
        },
        misc = {
          initial_workspace_tracking = 0,
          mouse_move_enables_dpms = true,
          key_press_enables_dpms = false,
        },
        animations = {
          enabled = true,
        },
        decoration = {
          rounding = 10,
          blur = {
            enabled = true,
            size = 5,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = false,
          },
        },
      })

      hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
      hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
      hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
      hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })

      hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
      hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
      hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
      hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
      hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })

      hl.bind("SUPER + Return", hl.dsp.exec_cmd("${terminal}"))
      hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("/run/current-system/sw/bin/zsh -c rofi-launcher"))
      hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("rofi-pass"))
      hl.bind("SUPER + Y", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
      hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("web-search"))
      hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("wallsetter"))
      hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -rs"))
      hl.bind("SUPER + W", hl.dsp.exec_cmd("${browser}"))
      hl.bind("SUPER + E", hl.dsp.exec_cmd("emopicker9000"))
      hl.bind("SUPER + S", hl.dsp.exec_cmd("screenshootin"))
      hl.bind("Print", hl.dsp.exec_cmd("screenshootin"))
      hl.bind("SUPER + D", hl.dsp.exec_cmd("discord"))
      hl.bind("SUPER + O", hl.dsp.exec_cmd("obs"))
      hl.bind("SUPER + C", hl.dsp.exec_cmd("hyprpicker -a"))
      hl.bind("SUPER + G", hl.dsp.exec_cmd("gimp"))
      hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("godot4"))
      hl.bind("SUPER + T", hl.dsp.exec_cmd("thunar"))
      hl.bind("SUPER + M", hl.dsp.exec_cmd("spotify"))
      hl.bind("SUPER + Q", hl.dsp.window.close())
      hl.bind("SUPER + P", hl.dsp.window.pseudo())
      hl.bind("SUPER + F", hl.dsp.window.fullscreen())
      hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
      hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.exit())
      hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
      hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
      hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
      hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
      hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
      hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
      hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
      hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
      hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
      hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
      hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
      hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
      hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
      hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
      hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
      hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
      hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
      hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }))
      hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }))
      hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
      hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
      hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
      hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
      hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
      hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
      hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
      hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.move({ workspace = "special" }))
      hl.bind("SUPER + SPACE", hl.dsp.workspace.toggle_special())
      hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
      hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
      hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
      hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
      hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
      hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
      hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
      hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
      hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
      hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
      hl.bind("SUPER + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("SUPER + CTRL + left", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
      hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
      hl.bind("ALT + Tab", hl.dsp.window.alter_zorder({ mode = "top" }))
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
      hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))
    '';

  };

  # Scripts
  home.packages = [
    pkgs.flameshot
    (import ../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../scripts/screenshootin.nix { inherit pkgs; })
    (import ../scripts/task-waybar.nix { inherit pkgs; })
    (import ../scripts/list-hypr-bindings.nix {inherit pkgs;
                                               inherit host;
                                                 })
  ];

  home.file."Pictures/Wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };

  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    savePath=/home/${username}/Pictures/Screenshots
    savePathFixed=true
    useGrimAdapter=true
  '';

  # Swappy is also used by the Emacs screenshot command.
  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=/home/${username}/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 10;
        hide_cursor = true;
        no_fade_in = false;
      };
      # background = [
      #   {
      #     path = "/home/${username}/Pictures/Wallpapers/city-view.jpeg";
      #     blur_passes = 3;
      #     blur_size = 8;
      #   }
      # ];
      image = [
        {
          path = "/home/${username}/Pictures/Wallpapers/sylvanas_1500x2070.jpeg";
          size = 150;
          border_size = 4;
          border_color = "rgb(0C96F9)";
          rounding = -1; # Negative means circle
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
      # input-field = [
      #   {
      #     size = "200, 50";
      #     position = "0, -80";
      #     monitor = "";
      #     dots_center = true;
      #     fade_on_empty = false;
      #     font_color = "rgb(CFE6F4)";
      #     inner_color = "rgb(657DC2)";
      #     outer_color = "rgb(0D0E15)";
      #     outline_thickness = 5;
      #     placeholder_text = "Password...";
      #     shadow_passes = 2;
      #   }
      # ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout =  "systemctl suspend";
        }
      ];
    };
  };

}
