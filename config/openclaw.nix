{ config, inputs, lib, pkgs, ... }:
let
  upstream = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw-gateway;
  proxy = "http://127.0.0.1:10808";
  environment = {
    HTTP_PROXY = proxy;
    HTTPS_PROXY = proxy;
    ALL_PROXY = proxy;
    http_proxy = proxy;
    https_proxy = proxy;
    all_proxy = proxy;
    NO_PROXY = "localhost,127.0.0.1,::1,internal.domain";
    no_proxy = "localhost,127.0.0.1,::1,internal.domain";
    # Package ownership stays with Nix; interactive JSON and OAuth stay writable.
    OPENCLAW_NIX_MODE = "0";
    OPENCLAW_DISABLE_PERSISTED_PLUGIN_REGISTRY = "0";
  };
  openclaw = pkgs.writeShellScriptBin "openclaw" ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") environment)}
    exec ${upstream}/bin/openclaw --profile plus "$@"
  '';
  stateDir = "${config.home.homeDirectory}/.openclaw-plus";
in
{
  home.packages = [ openclaw ];

  # Keep OAuth credentials and gateway tokens out of both Git and /nix/store.
  # Merge only non-secret defaults into the existing interactive configuration.
  home.activation.openclawDefaults = lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p -m 700 ${lib.escapeShellArg stateDir}
    if [ -z "''${DRY_RUN_CMD:-}" ]; then
      target=${lib.escapeShellArg "${stateDir}/openclaw.json"}
      if [ ! -f "$target" ]; then
        printf '{}\n' > "$target"
        chmod 600 "$target"
      fi
      temp=$(${pkgs.coreutils}/bin/mktemp "${stateDir}/.config.XXXXXX")
      if ${pkgs.jq}/bin/jq '
        .gateway.mode //= "local" |
        .gateway.port //= 18789 |
        .gateway.bind //= "loopback" |
        .gateway.auth.mode //= "token" |
        .agents.defaults.model.primary //= "openai/gpt-6.1-sol" |
        .agents.defaults.modelPolicy.allow //= ["openai/gpt-6.1-sol"]
      ' "$target" > "$temp"; then
        if ! ${pkgs.diffutils}/bin/diff -q <(${pkgs.jq}/bin/jq -S . "$target") <(${pkgs.jq}/bin/jq -S . "$temp") >/dev/null; then
          stamp=$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S-%N)
          ${pkgs.coreutils}/bin/cp -p "$target" "$target.before-nix.$stamp.bak"
          ${pkgs.coreutils}/bin/mv "$temp" "$target"
        else
          ${pkgs.coreutils}/bin/rm -f "$temp"
        fi
      else
        ${pkgs.coreutils}/bin/rm -f "$temp"
        exit 1
      fi
      # Retire the manual upgrade override, which would mask the managed ExecStart.
      override="${config.xdg.configHome}/systemd/user/openclaw-gateway.service.d/upgrade.conf"
      if [ -f "$override" ]; then
        ${pkgs.coreutils}/bin/mv "$override" "${stateDir}/upgrade-service.before-nix.bak"
      fi
    fi
  '';

  systemd.user.services.openclaw-gateway = {
    Unit = {
      Description = "OpenClaw Gateway (official Nix, plus profile)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${openclaw}/bin/openclaw gateway run";
      WorkingDirectory = config.home.homeDirectory;
      Environment = lib.mapAttrsToList (name: value: "${name}=${value}") environment;
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
