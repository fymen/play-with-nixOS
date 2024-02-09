{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";

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

    
    # Colorscheme
    nix-colors.url = "github:fymen/nix-colors/test";

    # Personal secrets
    mysecrets = {
      url = "git+ssh://git@github.com/fymen/secrets?ref=main";
      flake = false;
    };
  };
  outputs = { self, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [ inputs.nixos-flake.flakeModule ];

      flake =
        let
          mkNixosConfig = userName: hostName:
            self.nixos-flake.lib.mkLinuxSystem rec {
              nixpkgs.hostPlatform = "x86_64-linux";
              imports = [
                self.nixosModules.common # See below for "nixosModules"!
                self.nixosModules.linux
                # Your machine's configuration.nix goes here
                ./hosts/${hostName}/configuration.nix
                # Your home-manager configuration
                self.nixosModules.home-manager
                {
                  home-manager.users.${userName} = {
                    imports = [
                      self.homeModules.common # See below for "homeModules"!
                      self.homeModules.linux
                      ./home/${userName}
                    ];
                  };
                }
              ];
            };
        in
          {
            # Configurations for Linux (NixOS) machines
            nixosConfigurations = {
              "laptop" = mkNixosConfig "oscar" "laptop";
              "racknerd" = mkNixosConfig "hildar" "racknerd";
              "vm" = mkNixosConfig "oscar" "vm";
            };

            # Configurations for macOS machines
            darwinConfigurations = {
              m2 = self.nixos-flake.lib.mkMacosSystem {
                nixpkgs.hostPlatform = "aarch64-darwin";
                imports = [
                  self.nixosModules.common # See below for "nixosModules"!
                  self.nixosModules.darwin
                  # Your machine's configuration.nix goes here
                  ({ pkgs, ... }: {
                    # Used for backwards compatibility, please read the changelog before changing.
                    # $ darwin-rebuild changelog
                    system.stateVersion = 4;
                  })
                  # Your home-manager configuration
                  self.darwinModules_.home-manager
                  {
                    home-manager.users.oscar = {
                      imports = [
                        self.homeModules.common # See below for "homeModules"!
                        self.homeModules.darwin
                      ];
                      home.stateVersion = "23.11";
                    };
                  }
                ];
              };
            };

            # All nixos/nix-darwin configurations are kept here.
            nixosModules = {
              # Common nixos/nix-darwin configuration shared between Linux and macOS.
              common = { pkgs, ... }: {
                environment.systemPackages = with pkgs; [
                  hello
                ];
              };
              # NixOS specific configuration
              linux = {
                imports = [
                  inputs.nur.nixosModules.nur
                  inputs.agenix.nixosModules.default
                ];
              };
              # nix-darwin specific configuration
              darwin = { pkgs, ... }: {
                security.pam.enableSudoTouchIdAuth = true;
              };
            };

            # All home-manager configurations are kept here.
            homeModules = {
              # Common home-manager configuration shared between Linux and macOS.
              common = { pkgs, ... }: {
              };
              # home-manager config specific to NixOS
              linux = {
                imports = [inputs.nix-colors.homeManagerModule
                           inputs.nur.hmModules.nur];
              };
              # home-manager config specifi to Darwin
              darwin = {
                targets.darwin.search = "Bing";
              };
            };
          };
    };
}
