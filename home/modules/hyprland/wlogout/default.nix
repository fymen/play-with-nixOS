{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    wlogout
  ];

  programs.wlogout.enable = true;

  # xdg.configFile = {
  #   "wlogout/layout".source = ./layout;
  #   "wlogout/style.css".source = ./style.css;
  #   "wlogout/icons" = {
  #     source = ./icons;
  #     recursive = true;
  #   };
  # };
}
