{
  config,
  inputs,
  pkgs,
  ...
}:
{
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode"
                                    "JetBrainsMono"
                                    "InconsolataLGC"]; })
    open-sans
    source-sans-pro
    font-awesome
    etBook

    # Chinese fonts
    wqy_zenhei
    wqy_microhei
    arphic-uming
    arphic-ukai
  ];
}
