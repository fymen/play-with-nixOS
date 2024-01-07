{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Inconsolata:size=10";
        dpi-aware = true;
        pad = "2x2 center";
      };
      cursor = {
        color = "1A1826 D9E0EE"; # Cattpuccin
        blink = false;
        style = "block";
        beam-thickness = "0.8";
      };
      colors = {
        # Cattpuccin macchiato
        alpha = "1.0";
        foreground = "DCDCCC"; # Text
        background = "2B2B2B"; # Base
        regular0 = "494d64"; # Surface 1
        regular1 = "ed8796"; # red
        regular2 = "a6da95"; # green
        regular3 = "eed49f"; # yellow
        regular4 = "8aadf4"; # blue
        regular5 = "f5bde6"; # pink
        regular6 = "8bd5ca"; # teal
        regular7 = "b8c0e0"; # Subtext 1
        bright0 = "5b6078"; # Surface 2
        bright1 = "ed8796"; # red
        bright2 = "a6da95"; # green
        bright3 = "eed49f"; # yellow
        bright4 = "8aadf4"; # blue
        bright5 = "f5bde6"; # pink
        bright6 = "8bd5ca"; # teal
        bright7 = "a5adcb"; # Subtext 0
      };
    };
  };
}
