{
  config,
  inputs,
  pkgs,
  ...
}:
{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.inconsolata-lgc
    open-sans
    source-sans-pro
    font-awesome
    etBook

    # Chinese fonts
    wqy_zenhei
    wqy_microhei
    arphic-uming
    arphic-ukai
    noto-fonts-cjk-sans # 思源黑体
    noto-fonts-cjk-serif # 思源宋体

    lxgw-wenkai
    source-han-serif
    source-han-sans
  ];
}
