{ pkgs }:

pkgs.writeShellScriptBin "screenshootin" ''
  screenshot_dir="$HOME/Pictures/Screenshots"
  mkdir -p "$screenshot_dir"
  # Force the native Wayland Qt platform so flameshot runs as a Wayland
  # client, not through XWayland (QT_QPA_PLATFORM=wayland;xcb would fall
  # back to xcb). The grim adapter is still used for the actual capture.
  exec env QT_QPA_PLATFORM=wayland \
    ${pkgs.flameshot}/bin/flameshot gui --path "$screenshot_dir"
''
