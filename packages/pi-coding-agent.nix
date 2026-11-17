{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, ripgrep, fd, nodejs_24, libxcb }:
let
  releases = {
    x86_64-linux = {
      platform = "linux-x64";
      hash = "811c6f2c9e7aaee252b5404252e556fb713aa209c1f7f924226aa77d4ef70cb5";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "42805cd5615952fcbbfc9c56b04f8feb84395134952e169a6cdc8d7676975666";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation rec {
  pname = "pi-coding-agent";
  version = "1.5.2";
  src = fetchurl {
    url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-${release.platform}.tar.gz";
    sha256 = release.hash;
  };
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ stdenv.cc.cc.lib libxcb ];
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/pi $out/bin
    cp -r . $out/lib/pi/
    makeWrapper $out/lib/pi/pi $out/bin/pi \
      --prefix PATH : ${lib.makeBinPath [ ripgrep fd nodejs_24 ]}
    runHook postInstall
  '';
  meta = {
    description = "Pi coding agent with the upstream standalone runtime";
    homepage = "https://pi.dev/";
    license = lib.licenses.mit;
    platforms = builtins.attrNames releases;
    mainProgram = "pi";
  };
}
