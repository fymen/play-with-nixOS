{ config, lib, pkgs, ... }:

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
      configPassRepoUrl = mkOption{
        type = types.str;
        default = "${forgeUrl.default}/fymen/p-words.git";
      };
    };
  };

  config = mkIf cfg.enable {
    # Execute "systemctl --user enable emacs.service" after modifying this
    services.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
      startWithUserSession = "graphical";
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };

    home.activation = mkIf cfg.personal.enable {
      installPersonalEmacsConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH=$PATH:${lib.makeBinPath [ pkgs.git ]}

      if [ ! -d "$HOME/.emacs.d" ]; then
         git clone ${cfg.personal.configEmacsRepoUrl} $HOME/.emacs.d
      fi
      '';
    };

    home.packages = with pkgs; [
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science es]))
      emacs-all-the-icons-fonts

      (pkgs.writeShellScriptBin "espad" ''
        emacsclient --alternate-editor='false' --no-wait --create-frame --frame-parameters='(quote (name . "scratchpad"))'
        '')
    ];

    home.shellAliases = {
      ee="emacsclient -t";
      ec="emacsclient -c";
    };
  };
}
