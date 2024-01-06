{ config, lib, pkgs, inputs, ... }:

with lib;

let cfg = config.modules.editors.emacs;

in {
  options.modules.editors.emacs = {

    enable = mkOption{
      type = types.bool;
      default = false;
      description = ''
      Enable emacs configuration.
      '';
    };

    personal = rec {
      enable = mkOption{
        type = types.bool;
        default = false;
        description = ''
        Enable to fetch personal emacs configuration from github.
      '';
      };

      forgeUrl = mkOption {
        type = types.str;
        default = "git@github.com:";
      };
      configEmacsRepoUrl = mkOption{
        type = types.str;
        default = "${forgeUrl.default}fymen/.emacs.d.git";
      };
      configRoamRepoUrl = mkOption{
        type = types.str;
        default = "${forgeUrl.default}/fymen/roaming.git";
      };
    };
  };

  config = mkIf cfg.enable {
    # Execute "systemctl --user enable emacs.service" after modifying this
    # Do it when hyprland starts
    # services.emacs = {
    #   package = pkgs.emacs29-pgtk;
    #   enable = true;
    # };

    home.packages = with pkgs; [
      emacs29-pgtk
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science es]))
      mpv
      yt-dlp
      ripgrep
      silver-searcher

      emacs-all-the-icons-fonts
    ];

    home.shellAliases = {
      et="emacsclient -t";
      ec="emacsclient -c";
    };

    home.activation = mkIf cfg.personal.enable {
      installPersonalConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH=$PATH:${lib.makeBinPath [ pkgs.git ]}
      if [ ! -d "$HOME/.emacs.d" ]; then
         git clone ${cfg.personal.configEmacsRepoUrl} $HOME/.emacs.d
      fi

      if [ ! -d "$HOME/org/roam" ]; then
         git clone ${cfg.personal.configRoamRepoUrl} $HOME/org/roam
      fi

      '';
    };
  };
}
