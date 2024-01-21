{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.editors.emacs;
in {

  options.modules.editors.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable emacs configuration.
      '';
    };
    service = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable systemd user service for Emacs.
        '';
      };
    };

    personal = rec {
      enable = mkOption {
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
      configEmacsRepoUrl = mkOption {
        type = types.str;
        default = "${forgeUrl.default}fymen/.emacs.d.git";
      };
    };
  };

  config = mkIf cfg.enable {

    programs.emacs = {
      enable = true;
      package = pkgs.emacs;

      # package = pkgs.emacsWithPackagesFromUsePackage {
      #   config = ./emacs.org;
      #   defaultInitFile = true;
      #   alwaysEnsure = true;
      #   alwaysTangle = true;

      #   # Optionally provide extra packages not in the configuration file.
      #   extraEmacsPackages = epkgs: [
      #     #  epkgs.cask
      #   ];

      #   # Optionally override derivations.
      #   #      override = final: prev: {
      #   #        weechat = prev.melpaPackages.weechat.overrideAttrs(old: {
      #   #          patches = [ ./weechat-el.patch ];
      #   #        });
      #   #      };
      # };
    };

    services.emacs = mkIf cfg.service.enable {
      enable = true;
      package = pkgs.emacs;
      startWithUserSession = "graphical";
    };

    home.activation = mkIf cfg.personal.enable {
      installPersonalEmacsConfig = hm.dag.entryAfter ["writeBoundary"] ''
        PATH=$PATH:${lib.makeBinPath [pkgs.git]}

        if [ ! -d "$HOME/.emacs.d" ]; then
           git clone ${cfg.personal.configEmacsRepoUrl} $HOME/.emacs.d
        fi
      '';
    };

    home.packages = with pkgs; [
      (aspellWithDicts (dicts: with dicts; [en en-computers en-science es]))
      emacs-all-the-icons-fonts
      (pkgs.writeShellScriptBin "espad" ''
        emacsclient --alternate-editor='false' --no-wait --create-frame --frame-parameters='(quote (name . "scratchpad"))'
      '')
    ];

    home.shellAliases = {
      ee = "emacsclient -t";
      ec = "emacsclient -c";
    };
  };
}
