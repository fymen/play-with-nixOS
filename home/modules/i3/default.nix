{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    config.modifier = "Mod2";
    extraConfig = (builtins.readFile ./config);
  };

  xdg.configFile."i3blocks/config".text = ''
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

  home.file = {
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
