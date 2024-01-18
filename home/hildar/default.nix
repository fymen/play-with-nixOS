{
  inputs,
  system,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules/git.nix
    ../modules/tmux.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hildar";
  home.homeDirectory = "/home/hildar";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    btop
    bat
    du-dust
  ];

  programs = {
    # Replacement for ls
    eza = {
      enable = true;
      enableAliases = true;
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "${pkgs.vim}/bin/vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
