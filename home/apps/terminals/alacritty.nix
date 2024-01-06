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
      colors = {
        primary = {
          background = "#2B2B2B";
          foreground = "#DCDCCC";
        };
      };
    };
  };
}
