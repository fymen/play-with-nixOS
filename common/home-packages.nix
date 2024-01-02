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
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    font-manager
    # Terminal
    tmux
    alacritty

    python-with-my-packages
    # Image viewer
    feh
    gnome.eog
    flameshot
    # Editor
    emacs29-pgtk
    # Shells
    oh-my-zsh
    # Browsers
    firefox
    google-chrome
    # Data visualization
    gnuplot
    # Player
    mplayer
    mpv

    multimarkdown
    graphviz

    yt-dlp

    gimp
    imagemagick

    gdb

    evince
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
