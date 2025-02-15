{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.misc;
in {
  options.modules.misc = rec {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Personal miscellaneous.
      '';
    };

    forgeUrl = mkOption {
      type = types.str;
      default = "git@github.com:";
    };

    configRoamRepoUrl = mkOption {
      type = types.str;
      default = "${forgeUrl.default}/fymen/roaming.git";
    };

    configSecretsRepoUrl = mkOption {
      type = types.str;
      default = "${forgeUrl.default}/fymen/secrets.git";
    };

    configPassRepoUrl = mkOption {
      type = types.str;
      default = "${forgeUrl.default}/fymen/pcodes.git";
    };

    configBlogRepoUrl = mkOption {
      type = types.str;
      default = "${forgeUrl.default}/fymen/blog.git";
    };
  };

  config = mkIf cfg.enable {
    home.activation = {
      installPersonalConfig = hm.dag.entryAfter ["writeBoundary"] ''
        PATH=$PATH:${lib.makeBinPath [pkgs.git]}:${lib.makeBinPath [pkgs.openssh]}

        if [ ! -d "$HOME/.secrets" ]; then
           mkdir $HOME/.secrets
        fi

        if [ ! -d "$HOME/projects/personal/roam" ]; then
           git clone ${cfg.configRoamRepoUrl} $HOME/projects/personal/roam
        fi

        if [ ! -d "$HOME/projects/personal/blog" ]; then
           git clone ${cfg.configRoamRepoUrl} $HOME/projects/personal/blog
        fi

        if [ ! -d "$HOME/projects/personal/secrets" ]; then
           git clone ${cfg.configSecretsRepoUrl} $HOME/projects/personal/secrets
        fi

        if [ ! -d "$HOME/.password-store" ]; then
           git clone ${cfg.configPassRepoUrl} $HOME/.password-store
        fi

      '';
    };
  };
}
