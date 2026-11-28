{ config, lib, osConfig, pkgs, ... }:
let
  stateDir = "${config.xdg.stateHome}/daily-report";
  reportDir = "${config.home.homeDirectory}/hworkspace/daily-report";
  configDir = "${config.xdg.configHome}/daily-report";
  hermesHome = "${config.home.homeDirectory}/.hermes";
  localLlama = osConfig.services.llama-cpp.settings;
  python = pkgs.python3.withPackages (ps: [ ps.defusedxml ps.requests ]);
  hermes = lib.getExe config.programs.hermes-agent.package;
  report = pkgs.writeShellApplication {
    name = "daily-report";
    text = ''
      exec ${python}/bin/python3 -B ${../scripts/daily-report.py} "$@" \
        --state ${lib.escapeShellArg stateDir} \
        --output-dir ${lib.escapeShellArg reportDir} \
        --target-file ${lib.escapeShellArg "${configDir}/target"} \
        --model-config ${lib.escapeShellArg "${configDir}/model.json"} \
        --hermes ${hermes}
    '';
  };
  # Hermes requires physical scripts beneath HERMES_HOME/scripts, not store symlinks.
  cronScript = action: pkgs.writeShellScript "daily-report-${action}.sh" ''
    set -euo pipefail
    umask 077
    for attempt in 1 2 3; do
      if ${pkgs.coreutils}/bin/timeout 600 ${lib.getExe report} ${action}; then
        exit 0
      fi
      if [ "$attempt" -lt 3 ]; then
        ${pkgs.coreutils}/bin/sleep 120
      fi
    done
    echo "daily-report ${action} failed after 3 attempts" >&2
    exit 1
  '';
  setup = pkgs.writeShellApplication {
    name = "daily-report-setup";
    text = ''
      exec ${python}/bin/python3 -B ${../scripts/daily-report-setup.py} "$@" \
        --home ${lib.escapeShellArg hermesHome} \
        --hermes ${hermes} \
        --collect-script ${cronScript "collect"} \
        --send-script ${cronScript "send"}
    '';
  };
in
{
  home.packages = [ report setup ];

  # The loopback key is explicitly non-secret, as in config/hermes.nix.
  # Recipient ID and real credentials remain outside the Nix store.
  xdg.configFile."daily-report/model.json".text = builtins.toJSON {
    # Follow the server's startup model instead of maintaining another model name.
    models_preset = toString localLlama.models-preset;
    url = "http://${localLlama.host}:${toString localLlama.port}/v1/chat/completions";
    key = localLlama.api-key;
  };

  # Register/update job definitions, preserving the operator's pause/resume choices.
  # New jobs stay paused until `daily-report-setup --activate` is explicitly run.
  home.activation.dailyReportJobs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe setup}
  '';
}
