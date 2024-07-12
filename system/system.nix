{
  pkgs,
  lib,
  ...
}: {
  nix = {
    # settings.substituters = [ https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store ];
    settings.substituters = [ "https://mirror.nju.edu.cn/nix-channels/store" ];
    settings.experimental-features = ["nix-command" "flakes"];
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };
}
