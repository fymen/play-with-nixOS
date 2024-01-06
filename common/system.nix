{ pkgs, lib, ... }:

{
  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.experimental-features = ["nix-command" "flakes" ];
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };
}
