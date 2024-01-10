{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
    };
  };

  home.shellAliases = {
    q = "exit";
    c = "clear";
    open = "xdg-open";
  };

}
