{
  pkgs,
  config,
  ...
}: {
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
    size = 32;
  };

  # set dpi for 4k monitor
  xresources.properties = {
    # dpi for Xorg's font
    "Xft.dpi" = 240;
    # or set a generic dpi
    "*.dpi" = 240;
  };

  # gtk's theme settings, generate files:
  #   1. ~/.gtkrc-2.0
  #   2. ~/.config/gtk-3.0/settings.ini
  #   3. ~/.config/gtk-4.0/settings.ini
  gtk = {
    enable = true;

    font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
      size = 14;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      # https://github.com/catppuccin/gtk
      name = "Catppuccin-Macchiato-Compact-Pink-dark";
      package = pkgs.catppuccin-gtk.override {
        # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/themes/catppuccin-gtk/default.nix
        accents = ["pink"];
        size = "compact";
        variant = "mocha";
      };
    };
  };
}
