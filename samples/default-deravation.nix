{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    version = "2.4.4";

  in {
    packages.${system}.default =
      pkgs.stdenv.mkDerivation
        {
          name = "gnupg-${version}";

          src = pkgs.fetchurl {
            url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${version}.tar.bz2";
            sha256 = "1ijvx1dk7zr4vwippnwpb3ln2qicv3mqg8v7rs47dylhr8bf1sv7";
          };

          buildInputs = with pkgs; [
            libgpg-error libgcrypt libassuan libksba npth
          ];

          enableParallelBuilding = true;

          meta = with pkgs.lib; {
            homepage = "https://gnupg.org/";
            description =
              "GnuPG is a complete and free implementation of the OpenPGP standard as defined by RFC4880 (also known as PGP).";
            platforms = platforms.all;
          };
        };
  };
}
