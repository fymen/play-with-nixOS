{
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".tmux.conf" .source = dotfiles/tmux.conf;
    ".config/i3/config" .source = ./config;
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
