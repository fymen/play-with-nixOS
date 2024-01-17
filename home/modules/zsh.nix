{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
    };

    initExtra = ''eval "$(bw completion --shell zsh); compdef _bw bw;"'';

    shellAliases = {
      q = "exit";
      c = "clear";

      cat = "bat -p";
      grep = "rg";
    };
  };
}
