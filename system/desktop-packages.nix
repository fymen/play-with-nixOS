{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    tuigreet
    yad
    swappy
    grim
    slurp
  ];
}
