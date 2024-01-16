{ config, pkgs, inputs, system, lib, ... }:

{
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";

    # Configure AMD graphics
    videoDrivers = [ "amdgpu" ];

    displayManager = {
      autoLogin.enable = false;
      autoLogin.user = "oscar";

      defaultSession = "none+i3";

      gdm = {
        enable = true;
        wayland = true;
      };

      lightdm = {
        enable = false;
        greeters.enso = {
          enable = true;
        };
      };
    };

    desktopManager.gnome.enable = true;
    ## Configurations for I3
    dpi = 234;
    upscaleDefaultCursor = true;
    windowManager= {
      i3 = {
        enable = true;
        extraPackages = with pkgs; [
          j4-dmenu-desktop
          i3lock
          i3blocks
        ];
      };
    };
  };
}
