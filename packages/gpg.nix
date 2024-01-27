{ pkgs, ...}:
with pkgs;
let
  version = "2.4.4";
in
stdenv.mkDerivation
  {
    name = "gnupg-${version}";

    # https://nixos.wiki/wiki/Packaging/Binaries
    src = pkgs.fetchurl {
      url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${version}.tar.bz2";
      sha256 = "1ijvx1dk7zr4vwippnwpb3ln2qicv3mqg8v7rs47dylhr8bf1sv7";
    };

    buildInputs = [
      libgpg-error libgcrypt libassuan libksba npth
      adns bzip2 gnutls libusb1 openldap readline sqlite zlib
    ];

    configureFlags = [
      "--sysconfdir=/etc"
      "--with-libgpg-error-prefix=${libgpg-error.dev}"
      "--with-libgcrypt-prefix=${libgcrypt.dev}"
      "--with-libassuan-prefix=${libassuan.dev}"
      "--with-ksba-prefix=${libksba.dev}"
      "--with-npth-prefix=${npth}"
    ];

    enableParallelBuilding = true;

    meta = with lib; {
      homepage = "https://gnupg.org/";
      description =
        "GnuPG is a complete and free implementation of the OpenPGP standard as defined by RFC4880 (also known as PGP).";
      platforms = platforms.all;
    };
  }
