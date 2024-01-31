{pkgs, config, ...}: {
  home.packages = with pkgs; [
    tofi
  ];

  xdg.configFile = {
    "tofi/config" = {
      text = ''
        anchor = top
        width = 50%
        height = 40
        horizontal = true
        font-size = 19
        hint-font = true
        prompt-text = ""
        font = monospace
        outline-width = 0
        border-width = 0
        text-color = #${config.colorScheme.colors.base0D}
        background-color = #${config.colorScheme.colors.base00}
        selection-color = #${config.colorScheme.colors.base0C}
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
