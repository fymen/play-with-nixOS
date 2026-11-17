{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    tuigreet
    yad
    swappy
    awww
    grim
    slurp
  ];
}
