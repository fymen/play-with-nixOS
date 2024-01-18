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

      cat = "bat -p";
      grep = "rg";
    };
  };
}
