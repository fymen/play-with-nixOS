{
  config,
  inputs,
  ...
}: {
  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";
      window = {
        opacity = 1;
        padding = {
          x = 10;
          y = 10;
        };
      };

      selection.save_to_clipboard = true;

      keyboard.bindings = [
        {
          key = "I";
          mods = "Control|Shift";
          action = "IncreaseFontSize";
        }
        {
          key = "U";
          mods = "Control|Shift";
          action = "DecreaseFontSize";
        }
      ];

      font = {
        size = 12;
        normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          style = "Bold";
        };
      };

      colors = with config.colorscheme.colors; {
        primary = {
          background = "#${base00}";
          foreground = "#${base05}";
        };
        cursor = {
          text = "0xc0caf5";
          cursor = "0xffffff";
        };
        selection = {
          text = "CellForeground"; # "0xc0caf5";
          background = "0x33467c";
        };
        normal = {
          black = "0x15161e";
          red = "0xf7768e";
          green = "0x9ece6a";
          yellow = "0xe0af68";
          blue = "0x7aa2f7";
          magenta = "0xbb9af7";
          cyan = "0x7dcfff";
          white = "0xa9b1d6";
        };
        bright = {
          black = "0x414868";
          red = "0xf7768e";
          green = "0x9ece6a";
          yellow = "0xe0af68";
          blue = "0x7aa2f7";
          magenta = "0xbb9af7";
          cyan = "0x7dcfff";
          white = "0xc0caf5";
        };
      };
    };
  };
}
