{pkgs, ...}: {
  ## host qemu
  virtualisation.libvirtd.enable = false;
  programs.virt-manager.enable = false;

  # Distrobox and podman
  virtualisation = {
    podman = {
      enable = false;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = [pkgs.distrobox];
    };
  };
}
