{ config, pkgs, lib, ... }:
# From https://github.com/fbegyn/nixos-configuration/blob/main/services/tailscale.nix
let
  cfg = config.modules.tailscale;
  lock = "/tmp/tailscal-exitnode.lock";
in
with lib; {
  options.modules.tailscale = {
    enable = mkEnableOption "enables tailscale client services";

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
      example = "pkgs.tailscale";
      description = "pkg to use for tailscale";
    };

    port = mkOption {
      type = types.port;
      default = 41641;
      example = "8113";
      description = "The port to listen on for tunnel traffic (0=autoselect).";
    };

    routingFeature = mkOption {
      type = types.enum [ "none" "client" "server" "both" ];
      default = "none";
      example = "server";
      description = lib.mdDoc ''
        Enables settings required for Tailscale's routing features like subnet routers and exit nodes.

        To use these these features, you will still need to call `sudo tailscale up` with the relevant flags like `--advertise-exit-node` and `--exit-node`.

        When set to `client` or `both`, reverse path filtering will be set to loose instead of strict.
        When set to `server` or `both`, IP forwarding will be enabled.
      '';
    };

    notifySupport = mkOption {
      type = types.bool;
      default = false;
      example = "true";
      description = "Enable notifyd support";
    };

    cmd = mkOption {
      type = types.str;
      default = "${cfg.package}/bin/tailscaled --port ${toString cfg.port}";
      description = "Command to run tailscaled with";
    };

    autoprovision = {
      enable = mkEnableOption "enable auto provisioning";
      # key = mkOption {
      #   type = types.str;
      #   description = "API secret used to access tailscale";
      # };
      cmd = mkOption {
        type = types.str;
        default = "${cfg.package}/bin/tailscale up --operator=${cfg.autoprovision.operator} ${lib.concatStringsSep " "cfg.autoprovision.options}";
        # default = "${cfg.package}/bin/tailscale up --auth-key=${cfg.autoprovision.key} --operator=${cfg.autoprovision.operator} ${lib.concatStringsSep " "cfg.autoprovision.options}";
        description = "Command to use when running Tailscale";
      };
      operator = mkOption {
        type = types.str;
        default = "oscar";
        example = "oscar";
        description = "Operator that can control tailscale";
      };
      options = mkOption {
        type = types.listOf types.str;
        default = [];
        example = "[ \"--advertise-exit-node\" ]";
        description = "Options to pass to Tailscale";
      };
    };
  };

  config = mkIf cfg.enable {
    # environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    services.tailscale = {
      enable = false;
      package = cfg.package;
      useRoutingFeatures = "${cfg.routingFeature}";
    };
    systemd.services.tailscaled.enable = false;
    boot.kernel.sysctl = mkIf (cfg.routingFeature == "server" || cfg.routingFeature == "both") {
      "net.ipv4.conf.all.forwarding" = mkOverride 97 true;
      "net.ipv6.conf.all.forwarding" = mkOverride 97 true;
    };

    networking.firewall = {
      # enable the firewall
      enable = true;
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];
      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = mkIf (cfg.routingFeature == "client" || cfg.routingFeature == "both") "loose";
    };

    environment.systemPackages = mkIf (cfg.routingFeature == "client") [
      (pkgs.writeShellScriptBin "tailscale.sh" ''
      #!/usr/bin/env bash
      LOCK=${lock}
      if [ -e $LOCK ] ; then
         EXIT_NODE=
         rm $LOCK
      else
         EXIT_NODE=`${cfg.package}/bin/tailscale status | grep "exit node" | awk '{print $2}'`
         touch $LOCK
      fi
      ${cfg.package}/bin/tailscale set --exit-node-allow-lan-access --exit-node=$EXIT_NODE
      '')
      (pkgs.writeShellScriptBin "tailscale_stats.sh" ''
      #!/usr/bin/env bash
      LOCK=${lock}
      test -e $LOCK \
      && echo '{"text":"Connected","class":"connected","percentage":100}' \
      || echo '{"text":"Disconnected","class":"disconnected","percentage":0}'
      '')
    ];

    systemd.services.tailscale = {
      enable = true;
      description = "Tailscale node agent";
      documentation = [ "https://tailscale.com/kb/" ];
      path = [
        config.networking.resolvconf.package # for configuring DNS in some configs
        pkgs.procps     # for collecting running services (opt-in feature)
        pkgs.glibc
      ];
      after = [
        "network-pre.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ];
      wants = [ "network-pre.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        StartLimitIntervalSec = 0;
        StartLimitBurst = 0;
      };

      serviceConfig = {
        ExecStart = cfg.cmd;
        ExecStartPre = "${cfg.package}/bin/tailscaled --cleanup";
        ExecStopPost = "${cfg.package}/bin/tailscaled --cleanup";
        RuntimeDirectory = "tailscale";
        RuntimeDirectoryMode = 755;
        StateDirectory = "tailscale";
        StateDirectoryMode = 750;
        CacheDirectory = "tailscale";
        CacheDirectoryMode = 750;
        Restart = "on-failure";
      };
    };

    systemd.services.tailscale-autoprovision = mkIf cfg.autoprovision.enable {
      description = "automagically provision a tailscale machine";
      after = [ "network-pre.target" "NetworkManager.service" "systemd-resolved.service" "tailscale.service" ];
      wants = [ "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # authenticate to tailscale
        ${cfg.autoprovision.cmd}
      '';
    };
  };
}
