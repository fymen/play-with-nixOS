{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix = {
      url = "github:danth/stylix";
      # Firefox Color is disabled in config/firefox.nix; avoid its NUR input.
      inputs.nur.follows = "";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";
    
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    # Pin the source archive directly to avoid GitHub API rate limits.
    codex-desktop-linux.url = "https://codeload.github.com/ilysenko/codex-desktop-linux/tar.gz/ebb97799faa1a3437608e8f1812801a1c7b14b74";
    omp = {
      # Fetch pinned source without the rate-limited GitHub API.
      url = "github:can1357/oh-my-pi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Official OpenClaw Nix distribution, pinned to the validated 2026.10.7 release.
    nix-openclaw.url = "github:openclaw/nix-openclaw/4b261b08c173467dc41db7b43d8265529c435055";


    hypruse = {
      url = "github:IlyasKhallouki/hypruse";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url  = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal secrets
    mysecrets = {
      url = "git+ssh://git@github.com/fymen/secrets?ref=main";
      flake = false;
    };

  };

  outputs = { nixpkgs, home-manager, ... } @inputs:
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
        oracle-vps = {
          system = "x86_64-linux";
          username = "oscar";
          useHomeManager = true;
          useStylix = false;
          useAgenix = true;
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

      checks.x86_64-linux.script-tests =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          python = pkgs.python3.withPackages (ps: [ ps.defusedxml ps.requests ]);
        in
        pkgs.runCommand "offline-script-tests" { nativeBuildInputs = [ python ]; } ''
          export PYTHONDONTWRITEBYTECODE=1
          export HOME="$TMPDIR"
          python -m unittest discover -s ${./scripts} -p 'test_*.py'
          touch "$out"
        '';

      checks.x86_64-linux.bootstrap-lint =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in pkgs.runCommand "bootstrap-config-lint" { nativeBuildInputs = [ pkgs.statix ]; } ''
          statix check ${./config/misc.nix}
          statix check ${./config/daily-report.nix}
          touch "$out"
        '';

      devShells.x86_64-linux.default =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in pkgs.mkShell {
          packages = [
            (pkgs.python3.withPackages (ps: [ ps.defusedxml ps.requests ]))
            pkgs.statix
            pkgs.alejandra
            pkgs.gnumake
          ];
        };
    };

}
