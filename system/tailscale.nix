{ ... }: {
  # Use the upstream NixOS unit for state, restart handling, and firewall ports.
  # Existing /var/lib/tailscale state is retained; new nodes need `tailscale up`.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Tailnet traffic follows the same host firewall rules as other traffic.
  # SSH is opened by services.openssh; expose other services explicitly per host.
}
