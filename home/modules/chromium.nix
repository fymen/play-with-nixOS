{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };

    dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
    extensions = [
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
      { id = "enjjhajnmggdgofagbokhmifgnaophmh";} # Resolution Zoom to adapt HiDPI monitor
      { id = "mgijmajocgfcbeboacabfgobmjgjcoja";} # Google dictionary
    ];
  };
}
