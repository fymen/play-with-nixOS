{ pkgs }:

pkgs.writeShellScriptBin "screenshootin" ''
  screenshot_dir="$HOME/Pictures/Screenshots"
  mkdir -p "$screenshot_dir"
  exec ${pkgs.flameshot}/bin/flameshot gui --path "$screenshot_dir"
''
