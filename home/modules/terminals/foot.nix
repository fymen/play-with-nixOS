{ config, inputs, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;
    package = pkgs.foot;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Inconsolata:size=10";
        dpi-aware = true;
        pad = "2x2 center";
      };
      mouse.hide-when-typing = "yes";
      cursor = with config.colorscheme.colors; {
        color = "${base00} ${base05}"; # Cattpuccin
        blink = false;
        style = "beam";
        beam-thickness = "0.8";
      };
      colors = with config.colorscheme.colors; {
        # Cattpuccin macchiato
        alpha = "1.0";

        foreground = "${base05}"; # Text
        background = "${base00}"; # Base
        regular0 = "${base03}"; # Surface 1
        regular1 = "${base08}"; # red
        regular2 = "${base0B}"; # green
        regular3 = "${base0A}"; # yellow
        regular4 = "${base0D}"; # blue
        regular5 = "${base09}"; # pink  ?
        regular6 = "${base0C}"; # teal
        regular7 = "${base07}"; # Subtext 1
        bright0 = "${base04}"; # Surface 2
        bright1 = "${base08}"; # red
        bright2 = "${base0B}"; # green
        bright3 = "${base0A}"; # yellow
        bright4 = "${base0D}"; # blue
        bright5 = "${base09}"; # pink
        bright6 = "${base0C}"; # teal
        bright7 = "${base07}";

      };
    };
  };
}
