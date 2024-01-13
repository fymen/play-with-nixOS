{ inputs, system, config, pkgs, ... }:

{

  programs.zathura = {
    enable = true;
    options = with config.colorscheme.colors; {

      default-bg = "#${base00}";
      default-fg = "#${base01}";

      statusbar-bg = "#${base04}";
      statusbar-fg = "#${base02}";

      inputbar-bg = "#${base00}";
      inputbar-fg = "#${base07}";

      notification-bg = "#${base00}";
      notification-fg = "#${base07}";

      notification-error-bg = "#${base00}";
      notification-error-fg = "#${base08}";

      notification-warning-bg = "#${base00}";
      notification-warning-fg = "#${base08}";

      highlight-color = "#${base0A}";
      highlight-active-color = "#${base0D}";

      completion-bg = "#${base01}";
      completion-fg = "#${base0D}";

      completion-highlight-bg = "#${base07}";
      completion-highlight-fg = "#${base0D}";


      # completion-group-bg = "#${base05}";
      # completion-group-fg = "#${base0B}";

      recolor-darkcolor = "#${base00}";
      recolor-lightcolor = "#${base06}";

      # index-bg = "#${base06}";
      # index-fg = "#${base01}";
      # index-active-bg = "#${base04}";
      # index-active-fg = "#${base01}";

      recolor = false;
      recolor-keephue = false;

      selection-clipboard = "clipboard";

    };
    #     extraConfig = ''

    # set font "liberation mono 12"

    # set recolor "true"
    # # set recolor-keephue "true"

    # set page-padding 10
    # set scroll-wrap "true"
    # set statusbar-home-tilde "true"

    # map <C-.> scroll up
    # map <C-e> scroll down
    # map <C-o> scroll left
    # map <C-u> scroll right
    # map . scroll half-up
    # map e scroll half-down
    # map > scroll page-top
    # map E scroll page-bottom
    # map <A-.> scroll full-up
    # map <A-e> scroll full-down
    # map <PageUp> scroll half-up
    # map <PageDown> scroll half-down
    # map <BackSpace> scroll half-up
    # map <Space> scroll half-down
    # map h navigate previous
    # map n navigate next

    # map b adjust_window best-fit
    # map H adjust_window best-fit
    # map w adjust_window width
    # map W adjust_window width
    # map p rotate rotate-ccw
    # map <Left> rotate rotate-ccw
    # map , rotate rotate-cw
    # map <Right> rotate rotate-cw

    # map <C-s> search forward
    # map <C-r> search backward

    # map <A-g> goto
    # map g reload
    # map c recolor
    # map u follow
    # map <Return> toggle_presentation
    # map i toggle_index
    # map Q quit

    # map [presentation] <Return> toggle_presentation

    # # Index mode
    # map [index] i toggle_index
    # map [index] . navigate_index up
    # map [index] e navigate_index down
    # map [index] u navigate_index select
    # map [index] + navigate_index expand
    # map [index] - navigate_index collapse
    # map [index] <Tab> navigate_index toggle
    # # Unfortunately, there is no "toggle-all":
    # map [index] <ShiftTab> navigate_index expand-all
    # map [index] <A-ShiftTab> navigate_index collapse-all
    #     '';
  };
}
