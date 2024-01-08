{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # rofi-wayland
    tofi
    waybar
    hyprpaper
    pyprland
    xdg-desktop-portal-hyprland
    grim
    slurp
    wl-clipboard
    polkit_gnome
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = ''
# See https://wiki.hyprland.org/Configuring/Monitors/
# monitor=,highres,auto,auto
monitor=eDP-1,highres,auto,1

# unscale XWayland
xwayland {
  force_zero_scaling = false
}

# toolkit-specific scale
env = XCURSOR_SIZE,48


# See https://wiki.hyprland.org/Configuring/Keywords/ for more

# Execute your favorite apps at launch
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP
exec-once = gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
exec-once = /nix/store/$(ls -la /nix/store | grep polkit-gnome | grep '^d' | awk '{print $9}')/libexec/polkit-gnome-authentication-agent-1
exec-once = hyprpaper & waybar
exec-once = foot -e tmux
exec-once = pypr
# Emacs daemon executed by hyprland can't work with direnv mode. Wrapper it with tmux.
exec-once = tmux -c "emacs --daemon"

# Source a file (multi-file configs)
# source = ~/.config/hypr/myColors.conf

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = no
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 2
    gaps_out = 2
    border_size = 1
    col.active_border = rgba(F0DFAFAA) rgba(DFAF8FAA) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false
}

decoration {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    rounding = 10

    blur {
        enabled = true
        size = 3
        passes = 1
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes

    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = yes # you probably want this
}

master {
    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    new_is_master = true
}

gestures {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = off
}

misc {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
device:epic-mouse-v1 {
    sensitivity = -0.5
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
windowrule = noshadow, ^(foot)$
# windowrule = opacity 1.0 override 0.5 override,^(Alacritty)$

windowrule = float, ^(MPlayer)$
windowrule = center, ^(MPlayer)$

windowrule = float, calss:^(mpv)$

windowrule = float, ^(pavucontrol)$
windowrule = center, ^(pavucontrol)$
# windowrule = size 800 500, ^(pavucontrol)$

windowrule = float, ^(popweb.py)$
windowrule = center, ^(popweb.py)$

windowrulev2 = float,class:^(Google-chrome)$

workspace = 2, on-created-empty:[maximize] emacsclient --alternate-editor 'false' --create-frame
# workspace = 2, on-created-empty:[maximize] emacs

# workspace = magic, on-created-empty:[maximize] emacsclient --alternate-editor= --create-frame
#workspace = 3, on-created-empty:[maximize] firefox

# See https://wiki.hyprland.org/Configuring/Keywords/ for more
$mainMod = SUPER

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, RETURN, exec, foot -e tmux
bind = $mainMod SHIFT, Q, killactive,
bind = $mainMod SHIFT, ESCAPE, exit,
bind = $mainMod, E, exec, dolphin
bind = $mainMod SHIFT, SPACE, togglefloating,
bind = $mainMod, D, exec, tofi-drun --drun-launch=true
bind = $mainMod, M, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Pypr
bind = $mainMod, K, exec, pypr change_workspace +1
bind = $mainMod, J, exec, pypr change_workspace -1
bind = $mainMod, SPACE, exec, pypr toggle emacs
bind = $mainMod, F, exec, pypr toggle chrome

# Function keys
binde=, XF86AudioRaiseVolume, exec, amixer -q sset Master 5%+
binde=, XF86AudioLowerVolume, exec, amixer -q sset Master 5%-
bind =, XF86AudioMute, exec, amixer -q sset Master toggle

binde=, XF86MonBrightnessDown, exec, brightnessctl -d amdgpu_bl0 set 5%-
binde=, XF86MonBrightnessUp, exec, brightnessctl -d amdgpu_bl0 set 5%+

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Example special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Take a screenshot of the focused output and save it into screenshots
bind = , PRINT, exec, grim -o $(hyprctl monitors | grep -B 12 'focused: yes' | grep 'Monitor' | awk '{ print $2 }') -t jpeg ~/Pictures/screenshots-$(date +%Y-%m-%d_%H-%m-%s).jpg
# Take a screenshot of the selected region
bind = $mainMod, PRINT, exec, grim -t jpeg -g "$(slurp)" ~/Pictures/screenshots-$(date +%Y-%m-%d_%H-%m-%s).jpg
# Take a screenshot and save it to the clipboard
bind = $mainMod SHIFT, PRINT, exec, grim -g "$(slurp -d)" - | wl-copy
    '';
  };

  home.file = {
    # ".config/hypr/hyprland.conf" .source = ./hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf" .source = ./hypr/hyprpaper.conf;
    ".config/hypr/pyprland.toml" .source = ./hypr/pyprland.toml;
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
