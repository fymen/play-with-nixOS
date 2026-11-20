{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Keep the existing history path; retain more history without repeated entries.
    history = {
      size = 50000;
      save = 50000;
      saveNoDups = true;
      findNoDups = true;
      expireDuplicatesFirst = true;
      extended = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
    };

    shellAliases = {
      q = "exit";
      c = "clear";

      # Keep standard cat/grep semantics; opt in to the alternative tools.
      bcat = "bat --style=plain --paging=never";
      rgrep = "rg";
    };
  };
}
