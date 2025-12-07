{
  programs.git = {
    enable = true;
    settings.user.name = "Oscar Qi";
    settings.user.email = "fengmao.qi@gmail.com";

    ignores = [
      "*~"
      "*.swp"
      "*.pyc"
      "*.elc"
      "nohup.out"
      "*.log"
      "*-autoloads.el"
      "dir"
      "*.info"
      ".svn/"
      ".DS_Store"
      "*.iml"
      ".idea/"
      ".direnv/"
      "NEVER-COMMIT"
    ];
  };
}
