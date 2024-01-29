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
    FreeMono
    FreeSans
    open-sans
    source-sans-pro

    # Chinese fonts
    wqy_zenhei
    wqy_microhei
    arphic-uming
    arphic-ukai
  ];
}
