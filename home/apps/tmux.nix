{
  home.file = {
    ".tmux.conf" = {
      text = ''
      set -g prefix C-l
      set-window-option -g mode-keys vi
      set -g status-bg gray17
      set -g status-fg white
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ',screen-256color:Tc'
      '';
    };
  };
}
