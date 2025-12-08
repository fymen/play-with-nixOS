{pkgs, ...}:{

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5"; 
    fcitx5 = {
      addons = with pkgs; [
        # for flypy chinese input method
        fcitx5-rime
        # needed enable rime using configtool after installed
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
          DefaultIM = "wbpy";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "wbpy";
      };
      settings.addons = {
        pinyin.globalSection.EmojiEnabled = "True";
      };
    };
  };

  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
}
