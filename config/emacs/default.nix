
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


      package = pkgs.emacsWithPackagesFromUsePackage {
        config = ./emacs.org;
        defaultInitFile = true;
        alwaysEnsure = true;
        alwaysTangle = true;

        package = pkgs.emacs-pgtk;

        # Optionally provide extra packages not in the configuration file.
        extraEmacsPackages = epkgs: [
          (pkgs.callPackage ../../packages/pilish-grammars.nix {})
          (epkgs.treesit-grammars.with-grammars (grammars: with grammars; [
            tree-sitter-c tree-sitter-cpp tree-sitter-python tree-sitter-bash
            tree-sitter-json tree-sitter-nix tree-sitter-javascript
            tree-sitter-typescript tree-sitter-tsx tree-sitter-css tree-sitter-html
          ]))
        ];

        # Pin Pilish independently of the package archive.
        override = final: prev: {
          pilish = final.callPackage ../../packages/pilish.nix {};
        };

        # Optionally override derivations.
        #      override = final: prev: {
        #        weechat = prev.melpaPackages.weechat.overrideAttrs(old: {
        #          patches = [ ./weechat-el.patch ];
        #        });
        #      };
      };
    };

    home.file.".emacs.d/emacs.org".source = ./emacs.org;
    home.file.".emacs.d/elfeed.org".source = ./elfeed.org;

    services.emacs = mkIf cfg.service.enable {
      enable = true;
      package = config.programs.emacs.package;
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
      # Language servers used by the configured C/C++ and TypeScript hooks.
      clang-tools
      typescript-language-server
      typescript
      # agent-shell speaks ACP through this adapter, rather than the Codex CLI.
      codex-acp
      (pkgs.callPackage ../../packages/pi-coding-agent.nix {})
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      (texlive.combine {
        inherit (texlive) scheme-small collection-xetex collection-latexextra
          collection-langchinese collection-fontsrecommended latexmk;
      })

      plantuml

      (aspellWithDicts (dicts: with dicts; [en en-computers en-science es]))
      emacs-all-the-icons-fonts

      # (pkgs.callPackage ../../../packages/flameshot.nix {})
      grim
      slurp
      swappy

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
