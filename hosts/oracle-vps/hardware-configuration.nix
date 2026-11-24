{ lib, modulesPath, ... }:
{
  # Existing Ubuntu boot disk on the E2.1.Micro instance; preserve partitions.
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    configurationLimit = 3;
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8f40ea48-4763-4498-8ce2-b075819431e5";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7bae4ec2-7ce2-429a-bfa8-a6a32da78b5a";
    fsType = "ext4";
  };
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/EA2B-B579";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };
}
