{ config, lib, pkgs, ... }:
let
  cfg = config.modules.misc;
  # Accept both SCP-style SSH prefixes and URL-style forge roots.
  forgePrefix = if lib.hasSuffix ":" cfg.forgeUrl then cfg.forgeUrl
    else "${lib.removeSuffix "/" cfg.forgeUrl}/";
  repositories = {
    "projects/personal/roam" = cfg.configRoamRepoUrl;
    "projects/personal/blog" = cfg.configBlogRepoUrl;
    "projects/personal/secrets" = cfg.configSecretsRepoUrl;
    ".password-store" = cfg.configPassRepoUrl;
  };
  clone = target: url: ''
    destination=${lib.escapeShellArg "${config.home.homeDirectory}/${target}"}
    if [ ! -e "$destination" ] && [ ! -L "$destination" ]; then
      run mkdir -p -- "$(dirname "$destination")"
      if [ -n "''${DRY_RUN_CMD:-}" ]; then
        run echo "Would clone ${target}"
      else
        staging=$(mktemp -d "$destination.clone.XXXXXX")
        if ${pkgs.coreutils}/bin/timeout 120 env GIT_TERMINAL_PROMPT=0 \
          ${pkgs.git}/bin/git -c core.sshCommand='${pkgs.openssh}/bin/ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=yes' \
          clone -- ${lib.escapeShellArg url} "$staging"; then
          # -T avoids nesting a repository inside a concurrently created path.
          if ! mv -T -n -- "$staging" "$destination"; then
            echo "Could not install ${target}; existing path preserved" >&2
          fi
        else
          echo "Could not clone ${target}; retry on the next activation" >&2
        fi
        rm -rf -- "$staging"
      fi
    fi
  '';
in
{
  options.modules.misc = {
    enable = lib.mkEnableOption "personal repository bootstrap";
    forgeUrl = lib.mkOption {
      type = lib.types.str;
      default = "git@github.com:";
    };
    configRoamRepoUrl = lib.mkOption {
      type = lib.types.str;
      default = "${forgePrefix}fymen/roaming.git";
    };
    configSecretsRepoUrl = lib.mkOption {
      type = lib.types.str;
      default = "${forgePrefix}fymen/secrets.git";
    };
    configPassRepoUrl = lib.mkOption {
      type = lib.types.str;
      default = "${forgePrefix}fymen/pcodes.git";
    };
    configBlogRepoUrl = lib.mkOption {
      type = lib.types.str;
      default = "${forgePrefix}fymen/blog.git";
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.installPersonalConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Clones may contain private notes or credentials.
      (
        umask 077
        run mkdir -p -- ${lib.escapeShellArg "${config.home.homeDirectory}/.secrets"}
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList clone repositories)}
      )
    '';
  };
}
