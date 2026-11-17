{ config, ... }: {
  # Use the upstream NixOS unit for state, restart handling, and firewall ports.
  # Existing /var/lib/tailscale state is retained; new nodes need `tailscale up`.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Preserve the existing policy: trust traffic arriving from the tailnet.
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
