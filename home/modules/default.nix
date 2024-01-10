{ pkgs, ... }:

let
  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
    lxml # for eaf
    qrcode # eaf-file-browser
    pysocks # eaf-browser
    pymupdf # eaf-pdf-viewer
    pypinyin # eaf-file-manager
    psutil # eaf-system-monitor
    retry # eaf-markdown-previewer
    markdown

    pygments
    python
    venvShellHook
    numpy
    pandas
    opencv4
    matplotlib
    pyqt6
    pyqt6-sip
    pyqt6-webengine
    epc
    sexpdata
    browser-cookie3
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;

in
{
  imports = [
    ./emacs.nix
    ./i3
    ./tmux.nix
    ./zsh.nix
    ./git.nix
    ./terminals
    ./dunst.nix
    ./firefox.nix
    ./chromium.nix
    ./mpv.nix
    ./zathura.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    du-dust                     # Modernized "du"
    bat                         # Alternative to "cat"
    btop                        # Alternative to "top"
    nvtop-amd                       # Monitor GPU process
    starship
    fd                          # Alternative to "find"
    lazygit                     # Magit alternative

    grc                         # Colorize command output

    ydotool                     # Desktop automation tool, move mouse or something
    autojump                    # Jump around directories fastly

    neofetch
    pywal

    font-manager
    # Terminal
    tmux

    python-with-my-packages
    # Image viewer
    feh
    gnome.eog
    # Editor

    # Shells
    oh-my-zsh

    # Data visualization
    gnuplot
    mpv
    yt-dlp
    ripgrep
    silver-searcher


    multimarkdown
    graphviz

    gimp
    imagemagick

    gdb

    evince
    zathura

    libreoffice
    # Sound volume control
    pavucontrol

    networkmanager

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
}
