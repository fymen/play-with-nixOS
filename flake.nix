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
      system = "x86_64-linux";
      host = "desktop";
      username = "oscar";
    in
      {
        nixosConfigurations = {
          "${host}" = nixpkgs.lib.nixosSystem {
            specialArgs = {
	            inherit system;
              inherit inputs;
              inherit username;
              inherit host;
            };
            modules = [
              ./hosts/${host}/configuration.nix
              inputs.stylix.nixosModules.stylix
              inputs.agenix.nixosModules.default
              {
                environment.systemPackages = [
                  antigravity-nix.packages.x86_64-linux.default
                ];
              }
              home-manager.nixosModules.home-manager
              {
                home-manager.extraSpecialArgs = {
                  inherit username;
                  inherit inputs;
                  inherit host;
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "hm_backup";
                home-manager.users.${username} = import ./hosts/${host}/home.nix;
              }
            ];
          };
        };

      };

}
