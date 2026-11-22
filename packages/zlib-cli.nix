{ lib, stdenvNoCC, fetchurl, file }:

stdenvNoCC.mkDerivation rec {
  pname = "zlib-cli";
  version = "0.0.15";

  # Upstream builds with CGO_ENABLED=0. Pin the release archive and its digest;
  # this avoids upgrading the host's Go toolchain just to install this CLI.
  src = fetchurl {
    url = "https://github.com/heartleo/zlib/releases/download/v${version}/zlib_${version}_linux_x86_64.tar.gz";
    hash = "sha256-HJA+VvsX1SL/6WHSFPtHN+OlhGknM0mdCH5W3P8xpEM=";
  };

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true; # The upstream executable is statically linked.

  installPhase = ''
    runHook preInstall
    install -Dm755 zlib "$out/bin/zlib"
    install -Dm644 LICENSE "$out/share/licenses/zlib-cli/LICENSE"
    install -Dm644 README.md "$out/share/doc/zlib-cli/README.md"
    install -Dm644 README.zh.md "$out/share/doc/zlib-cli/README.zh.md"
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ file ];
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/zlib-check-home"
    export XDG_CONFIG_HOME="$HOME/.config"
    mkdir -p "$XDG_CONFIG_HOME"
    file "$out/bin/zlib"
    "$out/bin/zlib" version | grep -F 'v${version}'
    "$out/bin/zlib" --help > /dev/null
    "$out/bin/zlib" mcp --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Z-Library CLI and terminal interface with an optional MCP server";
    homepage = "https://github.com/heartleo/zlib";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zlib";
  };
}
