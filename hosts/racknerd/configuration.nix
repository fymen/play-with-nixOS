# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common/system.nix
      ../../common/system-packages.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "racknerd"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "American/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hildar = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      git
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJkAMrxKB6NCUZmezjy2byWL1UbmlWNfeOKcfheIGjMbMQt+pnhJNTOzWkW08BttidzGAaN1QppPm+7kPLQh1xaBqfQI+gJuSozblT9POvtQrZwQ1VM+YoGQHrw7Fg7Z0wSF+wtM2nKWa2/sV+OzXrnSaA9gZtfnSpG1QXn+dsaWriZ9q/FmZMwGHw03VAWBVgOZzZDJYTgfcSoBGyVrByz9IGmW2RMsF2sMo+fAQJoKGBnM1DSEsftp96eVWKP9qGj7hyQDYjNeduzNTih89oLq1f4eEF5z9gUIIkK7rDQB6Ds2J0AciLm6zKg75EGKlvyQxgZU9QiQZa0zWBTZpjRDmBH+k5Oxu7alZbXPqzwFYJw2iy9hm8DN2V8158Mkfv2hM15GOkp9uA9YRwREw+zxTS/PLvbzmlgm9LGfyHc2NDzlJViZDsmZUkII8gNXAcoPwHgzLpAkqXrPzQJA9NZHUIC67iXq6xFxtWDlMc3VbcwHifK4a1P3mXq8pho68= oscar@oscar-Vivobook-ASUSLaptop-M5402RA-M5402RA'' ];
  users.users.hildar.openssh.authorizedKeys.keys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJkAMrxKB6NCUZmezjy2byWL1UbmlWNfeOKcfheIGjMbMQt+pnhJNTOzWkW08BttidzGAaN1QppPm+7kPLQh1xaBqfQI+gJuSozblT9POvtQrZwQ1VM+YoGQHrw7Fg7Z0wSF+wtM2nKWa2/sV+OzXrnSaA9gZtfnSpG1QXn+dsaWriZ9q/FmZMwGHw03VAWBVgOZzZDJYTgfcSoBGyVrByz9IGmW2RMsF2sMo+fAQJoKGBnM1DSEsftp96eVWKP9qGj7hyQDYjNeduzNTih89oLq1f4eEF5z9gUIIkK7rDQB6Ds2J0AciLm6zKg75EGKlvyQxgZU9QiQZa0zWBTZpjRDmBH+k5Oxu7alZbXPqzwFYJw2iy9hm8DN2V8158Mkfv2hM15GOkp9uA9YRwREw+zxTS/PLvbzmlgm9LGfyHc2NDzlJViZDsmZUkII8gNXAcoPwHgzLpAkqXrPzQJA9NZHUIC67iXq6xFxtWDlMc3VbcwHifK4a1P3mXq8pho68= oscar@oscar-Vivobook-ASUSLaptop-M5402RA-M5402RA'' ];


  security.acme = {
    acceptTerms = true;
    defaults.email = "fengmao.qi@gmail.com";
  };

  services.nginx = {
    enable = true;
    virtualHosts."oncehigh.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/oncehigh.com";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
