{ pkgs, config, ... }:

{

  home.file.".config/rofi/config-long.rasi".text = ''
    @import "~/.config/rofi/config.rasi"
    window {
      width: 50%;
    }
    entry {
      placeholder: "🔎 Search       ";
    }
    listview {
      columns: 1;
      lines: 8;
      scrollbar: true;
    }
  '';

  home.file.".config/rofi/config-emoji.rasi".text = ''
    @import "~/.config/rofi/config-long.rasi"
    entry {
      width: 45%;
      placeholder: "🔎 Search Emoji's 👀";
    }
  '';

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig = {
        modi = "drun,filebrowser,run";
        show-icons = true;
        icon-theme = "Papirus";
        location = 0;
        font = "JetBrainsMono Nerd Font Mono 12";
        drun-display-format = "{icon} {name}";
        display-drun = " Apps";
        display-run = " Run";
        display-filebrowser = " File";
      };
    };
  };
}
