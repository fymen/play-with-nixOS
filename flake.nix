{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nur.url = "github:nix-community/NUR";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    agenix.url = "github:ryantm/agenix";

    # colorscheme
    nix-colors.url = "github:Misterio77/nix-colors";

    home = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = { self, nixpkgs, home, nix-colors, ... }@inputs:
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
          home-manager.extraSpecialArgs = {inherit inputs;
                                           inherit system;
                                          };
        }
      ];
    in
      {
        nixosConfigurations = {
          "laptop" = nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = {inherit inputs;
                           inherit system;
                          };
            modules = genericModules ++
                      [ ./hosts/laptop
                        { home-manager.users.oscar.imports =
                            [ ./home/home.nix
                              inputs.nix-colors.homeManagerModules.default
                              inputs.nur.hmModules.nur
                            ];
                        }
                        inputs.nur.nixosModules.nur
                        inputs.agenix.nixosModules.default
                      ];
          };

          "vm" = nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = { inherit inputs; };
            modules = genericModules ++ [ ./hosts/vm/configuration.nix
                                          { home-manager.users.oscar = import ./home/oscar-vm.nix; }
                                          inputs.agenix.nixosModules.default
                                        ];
          };
        };
      };
}
