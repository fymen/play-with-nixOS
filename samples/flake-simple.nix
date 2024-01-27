{
  description = "Kernel development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
      {
        devShells.${system}.default = pkgs.mkShell {
          packages = with pkgs; [
            sphinx

            pkg-config
            ncurses
            flex
            bison
            bc

            openssl

            elfutils

            autoconf
          ];


          env = {
            RUST_BACKTRACE = "full";
          };
        };
      };
}
