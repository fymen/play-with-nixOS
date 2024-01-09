{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tofi
  ];

  home.file = {
    ".config/tofi/config" = {
      text = ''
      anchor = top
      width = 50%
      height = 32
      horizontal = true
      font-size = 20
      hint-font = true
      prompt-text = ""
      font = monospace
      outline-width = 0
      border-width = 0
      text-color = #D0BF8F
      background-color = #0008
      selection-color = #DFAF8F
      min-input-width = 50
      result-spacing = 15
      padding-top = 0
      padding-bottom = 0
      padding-left = 0
      padding-right = 0
      '';
    };
  };
}
