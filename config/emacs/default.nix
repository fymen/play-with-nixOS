
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (pkgs) fetchurl;
  inherit (pkgs) fetchFromGitHub;

  # popweb-py-pkgs = pkgs.python311.withPackages (ps: [
  #   ps.pyqt6
  #   ps.pyqt6-sip
  #   ps.pyqt6-webengine
  #   ps.epc
  #   ps.sexpdata
  #   ps.browser-cookie3
  # ]);

  cfg = config.modules.editors.emacs;

  chgcursor-el = pkgs.emacs-pgtk.pkgs.trivialBuild rec {
    pname = "cursor-chg";
    version = "1.0";
    src = fetchurl {
      url = "https://raw.githubusercontent.com/emacsmirror/cursor-chg/71a22ee8f81dd309e1c0d357679b755cf1ad47f7/cursor-chg.el";
      hash = "sha256-oWQmT7uOSB+0fRrv2TLcqUgpb29PAQ2tnLIGmmGj9hw=";
    };
  };
  popweb = pkgs.emacs.pkgs.trivialBuild rec {
    pname = "popweb";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "fymen";
      repo = "popweb";
      rev = "2e2662f987e4638c5c5fc5cdfb4347565f74300b";
      sha256 = "132gcymzsaaryyk4nglv9pwmdrnspdn4r1ayjbh0mqg6xf9w7mvk";
    };

    preBuild = ''
    cp extension/dict/* ./
    '';
    postInstall = ''
    LISPDIR=$out/share/emacs/site-lisp
    install *.py $LISPDIR
    install *.js $LISPDIR
    '';
  };

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
          #  epkgs.cask
        ];

        # The cursor extension is maintained outside the package archive.
        override = final: prev: {
          cursor-chg = chgcursor-el;
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
      package = pkgs.emacs-pgtk;
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
      # agent-shell speaks ACP through this adapter, rather than the Codex CLI.
      codex-acp
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      (texlive.combine {
        inherit (texlive) scheme-small collection-xetex collection-latexextra
          collection-langchinese collection-fontsrecommended latexmk;
      })
      python3Packages.pygments

      (aspellWithDicts (dicts: with dicts; [en en-computers en-science es]))
      emacs-all-the-icons-fonts

      # (pkgs.callPackage ../../../packages/flameshot.nix {})
      grim
      slurp
      swappy

      # popweb-py-pkgs

      #      chgcursor-el
      popweb

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
