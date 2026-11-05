{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    tuigreet
    yad
    swappy
    swww
    grim
    slurp
  ];
}
