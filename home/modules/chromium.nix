{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
    extensions = [
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
      { id = "enjjhajnmggdgofagbokhmifgnaophmh";} # Resolution Zoom to adapt HiDPI monitor
      { id = "mgijmajocgfcbeboacabfgobmjgjcoja";} # Google dictionary
    ];
  };
}
