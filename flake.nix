{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    emacs-overlay = {
      url  = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Personal secrets
    mysecrets = {
      url = "git+ssh://git@github.com/fymen/secrets?ref=main";
      flake = false;
    };

    # Devshell
    treefmt-nix.url = "github:numtide/treefmt-nix";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, home-manager, antigravity-nix, ... } @inputs:
    let
      # Host configurations
      hosts = {
        desktop = {
          system = "x86_64-linux";
          username = "oscar";
          useHomeManager = true;
          useStylix = true;
          useAgenix = true;
        };
        laptop = {
          system = "x86_64-linux";
          username = "oscar";
          useHomeManager = true;
          useStylix = true;
          useAgenix = true;
        };
        vps = {
          system = "x86_64-linux";
          username = "hildar";
          useHomeManager = true;
          useStylix = false;
          useAgenix = false;
        };
        vm = {
          system = "x86_64-linux";
          username = "oscar";
          useHomeManager = false;
          useStylix = false;
          useAgenix = false;
        };
      };

      # Helper function to create NixOS configuration
      mkHost = hostname: { system, username, useHomeManager, useStylix, useAgenix }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit system inputs username;
            host = hostname;
          };
          modules = [
            ./hosts/${hostname}/configuration.nix
          ]
          ++ nixpkgs.lib.optionals useStylix [
            inputs.stylix.nixosModules.stylix
          ]
          ++ nixpkgs.lib.optionals useAgenix [
            inputs.agenix.nixosModules.default
          ]
          ++ nixpkgs.lib.optionals (useStylix || useAgenix) [
            {
              environment.systemPackages = [
                antigravity-nix.packages.${system}.default
              ];
            }
          ]
          ++ nixpkgs.lib.optionals useHomeManager [
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username inputs;
                host = hostname;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm_backup";
              home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
            }
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost hosts;
    };

}
