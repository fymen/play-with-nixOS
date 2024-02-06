{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Tailscale service";
    client.enable = mkEnableOption "Tailscale client";
    server.enable = mkEnableOption "Tailscale server";
  };

  config = mkIf cfg.enable {
    # enable the tailscale service
    services.tailscale = {
      enable = true;
      extraUpFlags = [ "--operator=${config.home.username}" ];
      useRoutingFeatures = "both";
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "tailscale.sh" ''
      #!/usr/bin/env bash
      tailscale status > /dev/null
      if [ $? -eq 0 ] ; then
         tailscale down
         echo "tailscale down..."
      else
          tailscale up
          echo "tailscale up..."
          sleep 1
          EXIT_NODE=`tailscale status | grep "exit node" | awk '{print $2}'`
          echo "set exit node as: $EXIT_NODE"
          tailscale set --exit-node-allow-lan-access --exit-node=$EXIT_NODE
      fi
      '')
      (pkgs.writeShellScriptBin "tailscale_stats.sh" ''
      #!/usr/bin/env bash
      tailscale status > /dev/null \
      && echo '{"text":"Connected","class":"connected","percentage":100}' \
      || echo '{"text":"Disconnected","class":"disconnected","percentage":0}'
      '')
    ];

    boot.kernel.sysctl = mkIf cfg.server.enable {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # Tailscale (with oneshot exit-node)
    systemd.services.tailscale-autoconnect = mkIf cfg.server.enable {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # otherwise authenticate with tailscale
      # ${tailscale}/bin/tailscale up --advertise-exit-node -authkey <key>
      ${tailscale}/bin/tailscale up --advertise-exit-node
    '';
    };

    # Open ports in the firewall.
    networking.firewall = mkIf cfg.server.enable {
      # enable the firewall
      enable = true;

      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
