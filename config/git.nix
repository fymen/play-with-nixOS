{
  programs.git = {
    enable = true;
    userName = "Oscar Qi";
    userEmail = "fengmao.qi@gmail.com";

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
