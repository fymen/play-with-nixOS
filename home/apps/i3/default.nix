{ config, lib, pkgs, ... }:
let
  mod = "Mod4";
in {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = ["DejaVu Sans Mono, FontAwesome 6"];

      keybindings = lib.mkOptionDefault {
        "${mod}+p" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        "${mod}+Shift+x" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";

        # Focus
        "${mod}+j" = "focus left";
        "${mod}+k" = "focus down";
        "${mod}+l" = "focus up";
        "${mod}+semicolon" = "focus right";

        # Move
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+l" = "move up";
        "${mod}+Shift+semicolon" = "move right";

        # My multi monitor setup
        "${mod}+m" = "move workspace to output DP-2";
        "${mod}+Shift+m" = "move workspace to output DP-5";
      };

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
        }
      ];
    };
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".tmux.conf" .source = dotfiles/tmux.conf;
    # ".config/i3/config" .source = ./config;
    ".config/i3blocks/config" = {
      text = ''
      [volume]
      command=volume
      #LABEL=♪
      LABEL=VOL
      interval=once
      signal=10
      #STEP=5%
      #MIXER=[determined automatically]
      #SCONTROL=[determined automatically]
      #NATURAL_MAPPING=0

      [brightness]
      command=echo BRI`brightnessctl | awk -F'[()]' '/Current brightness/ {print $2}'`
      interval=once
      signal=11

      [battery]
      command=battery
      markup=pango
      interval=60

      [time_date]
      command=date +" %a %d %b - %H:%M:%S"
      interval=1
      '';
    };

    "bin/battery" = {
      executable = true;
      source = ./battery.py;
    };

    "bin/volume" = {
      executable = true;
      source = ./volume.sh;
    };

  };
}
