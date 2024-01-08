{
  programs.zsh = {
    enable = true;
    envExtra = '' eval "$(direnv hook zsh)" '';
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
    };
  };
}
