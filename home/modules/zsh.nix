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
      open = "handlr open";

      cat = "bat -p";
      du = "dust";
      grep = "rg";
    };
  };
}
