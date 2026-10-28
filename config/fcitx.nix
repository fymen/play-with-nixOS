{pkgs, ...}:{

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5"; 
    fcitx5 = {
      addons = with pkgs; [
        # Rime with the Rime Ice schema and dictionaries
        (fcitx5-rime.override {
          rimeDataPkgs = [
            pkgs.rime-ice
          ];
        })
        qt6Packages.fcitx5-configtool
        qt6Packages.fcitx5-chinese-addons
        # fcitx5-mozc    # japanese input method
        fcitx5-gtk # gtk im module
        fcitx5-tokyonight # a theme
      ];
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "rime";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "rime";
      };
      settings.addons = {
        pinyin.globalSection.EmojiEnabled = "True";
      };
    };
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml".text = ''
    patch:
      __include: rime_ice_suggestion:/
      schema_list:
        - schema: rime_ice
  '';

  home.sessionVariables = {
    # GTK_IM_MODULE = "fcitx";
    # QT_IM_MODULE = "fcitx";
    # XMODIFIERS = "@im=fcitx";
  };
}
