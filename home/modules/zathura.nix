{
  inputs,
  system,
  config,
  pkgs,
  ...
}: {
  programs.zathura = {
    enable = true;
    options = with config.colorschemetest.colors; {
      # Personal tuned scheme
      default-bg = "#${base03}";
      default-fg = "#${base01}";

      inputbar-bg = "#${base05}";
      inputbar-fg = "#${base01}";
      statusbar-bg = "#${base08}";
      statusbar-fg = "#${base01}";

      completion-bg = "#${base05}";
      completion-fg = "#${base01}";
      completion-group-bg = "#${base05}";
      completion-group-fg = "#${base0B}";
      completion-highlight-bg = "#${base02}";
      completion-highlight-fg = "#${base01}";

      notification-bg = "#${base05}";
      notification-fg = "#${base00}";
      notification-warning-bg = "#${base04}";
      notification-warning-fg = "#${base00}";
      notification-error-bg = "#${base09}";
      notification-error-fg = "#${base00}";

      index-bg = "#${base06}";
      index-fg = "#${base01}";
      index-active-bg = "#${base04}";
      index-active-fg = "#${base01}";

      recolor-darkcolor = "#${base01}";
      recolor-lightcolor = "#${base06}";

      recolor = true;
      recolor-keephue = false;

      selection-clipboard = "clipboard";
    };
  };
}
