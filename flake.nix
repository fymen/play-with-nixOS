{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url  = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    
    # Colorscheme
    nix-colors.url = "github:fymen/nix-colors/test";
    # nix-colors.url = "/home/oscar/gitest/nix/nix-colors";

    # Personal secrets
    mysecrets = {
      url = "git+ssh://git@github.com/fymen/secrets?ref=main";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    home,
    mysecrets,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    genericModules = [
      {
        # This fixes things that don't use Flakes, but do want to use NixPkgs.
        nix.registry.nixos.flake = inputs.self;
        environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
        nix.nixPath = ["nixpkgs=${nixpkgs.outPath}"];
      }

      home.nixosModules.home-manager
      {
        nix.registry.nixos.flake = inputs.self;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];

    mkNixosConfig = user: hostName: wm:
      nixpkgs.lib.nixosSystem {

        specialArgs = {inherit inputs system mysecrets;
                       windowSystem = wm;
                      };
        modules =
          genericModules
          ++ [
            ./hosts/${hostName}/configuration.nix
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs system mysecrets;
                                     windowSystem = wm;
                                   };
                users.${user}.imports = [
                  ./home/${user}/default.nix
                  inputs.nix-colors.homeManagerModule
                  inputs.nur.hmModules.nur
                ];
              };
            }
            inputs.nur.nixosModules.nur
          ];
      };

    mkHomeManager = user: hostName: system: modules:
      home.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit inputs system;
        };

        modules = [
          inputs.nur.nixosModules.nur
          ./home/${user}-${hostName}
        ];
      }
      ++ modules;
  in {
    nixosConfigurations = {
      # username(can be find at ./home/), hostname(can be find at ./hosts/), desktop system ("wayland" or "xorg")
      "laptop" = mkNixosConfig "oscar" "laptop" "wayland";
      "racknerd" = mkNixosConfig "hildar" "racknerd" "";
      "vm" = mkNixosConfig "oscar" "vm";
    };

    homeConfigurations = {
      "oscar@m2" = mkHomeManager "oscar" "m2" "aarch64-darwin" [];
    };
  };
}
