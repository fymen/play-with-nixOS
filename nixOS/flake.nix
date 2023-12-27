# /etc/nixos/flake.nix
{
  inputs = {
    # NOTE: Replace "nixos-23.11" with that which is in system.stateVersion of
    # configuration.nix. You can also use latter versions if you wish to
    # upgrade.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = { self, nixpkgs, home-manager, ... }: {
    # NOTE: 'nixos' is the default hostname set by the installer
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      # NOTE: Change this to aarch64-linux if you are on ARM
      system = "x86_64-linux";
      modules = [
        ./hosts/laptop/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.oscar = import ./home-manager/home.nix;
          };

           nix = {
             settings.experimental-features = ["nix-command" "flakes" ];
           };
        }
      ];
    };

    nixosConfigurations.vmware = nixpkgs.lib.nixosSystem {
      # NOTE: Change this to aarch64-linux if you are on ARM
      system = "x86_64-linux";
      modules = [
        ./hosts/vm/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.oscar = import ./home-manager/home.nix;
          };

           nix = {
             settings.experimental-features = ["nix-command" "flakes" ];
           };
        }
      ];
    };

  };
}
