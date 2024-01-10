{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
    };

    shellAliases = {
      q = "exit";
      c = "clear";
      open = "xdg-open";

      cat = "bat -p";
      du = "dust";
      grep = "rg";
    };
  };
}
