{pkgs, ... }:

{
  ## host qemu
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;

  ## guest
  #  virtualisation.qemu.guestAgent.enable = true;


  # Distrobox and podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = [ pkgs.distrobox ];
    };
  };
}
