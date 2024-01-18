{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    waylogout
    swaylock-effects
  ];

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = with config.colorscheme.colors; {
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      ring-color = "${base0E}";
      key-hl-color = "${base08}";
      line-color = "00000000";
      inside-color = "00000088";
      separator-color = "00000000";
      grace = 2;
      fade-in = 0.2;
      show-failed-attempts = true;
    };
  };

  xdg.configFile = {
    "waylogout/config" = with config.colorscheme.colors; {
      text = ''
        hide-cancel
        screenshots
        # font="Baloo 2"
        # fa-font="Font Awesome 6 Free"
        effect-blur=7x5
        indicator-thickness=20
        ring-color=888888aa
        inside-color=88888866
        text-color=eaeaeaaa
        line-color=00000000
        ring-selection-color=${base08}aa
        inside-selection-color=${base08}66
        text-selection-color=eaeaeaaa
        line-selection-color=00000000
        lock-command="swaylock"
        logout-command="hyprctl dispatch exit 0"
        suspend-command="swaylock -f && systemctl suspend"
        # hibernate-command="echo hibernate"
        reboot-command="systemctl reboot"
        poweroff-command="systemctl poweroff"
        # switch-user-command="echo switch"
        selection-label

        indicator-separation=10
      '';
    };
  };
}
