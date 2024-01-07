{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nur.url = "github:nix-community/NUR";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    agenix.url = "github:ryantm/agenix";

    home = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = { self, nixpkgs, home, agenix, nur, ... }@inputs:
    let
      system = "x86_64-linux";
      genericModules = [
        {
          # This fixes things that don't use Flakes, but do want to use NixPkgs.
          nix.registry.nixos.flake = inputs.self;
          environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
          nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];
        }

        home.nixosModules.home-manager {
          nix.registry.nixos.flake = inputs.self;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    in
      {
        nixosConfigurations = {
          "laptop" = nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = { inherit inputs;
                            inherit system;
                          };
            modules = genericModules ++ [ ./hosts/laptop
                                          { home-manager.users.oscar.imports = [ ./home/oscar-laptop.nix
                                                                                 nur.hmModules.nur
                                                                               ];
                                          }
                                          nur.nixosModules.nur
                                          agenix.nixosModules.default];

          };

          "vm" = nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = { inherit inputs; };
            modules = genericModules ++ [ ./hosts/vm/configuration.nix
                                          { home-manager.users.oscar = import ./home/oscar-vm.nix; }
                                          agenix.nixosModules.default];
          };
        };
      };
}
