{ config, inputs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 20.0;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
      colors = with config.colorscheme.colors; {
        primary = {
          background = "#${base00}";
          foreground = "#${base05}";
        };
      };
    };
  };
}
