{ callPackage, fetchFromGitHub }:
let
  # Reuse the upstream desktop packaging, pinned independently of flake.lock.
  # This revision installs Magpie 0.1.4783 and pins each release asset's SHA-256.
  upstream = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie-releases";
    rev = "4cb95521ec2ceb474b203258c3c23198cbb6c091";
    hash = "sha256-f/5JEfdQLfsIRiy4oUgA4I4wyqbAwWPCDZLCMAAlfH8=";
  };
  magpie = callPackage "${upstream}/nix/package.nix" {
    sources = builtins.fromJSON (builtins.readFile "${upstream}/nix/sources.json");
  };
in
magpie.overrideAttrs (old: {
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    # Even CLI commands may migrate application state: never use the real HOME.
    export HOME="$TMPDIR/magpie-check-home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_DATA_HOME="$HOME/.local/share"
    export MAGPIE_NO_ACCOUNTS=1
    mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
    "$out/bin/magpie" version | grep -F '${old.version}'
    "$out/bin/magpie" --help > /dev/null
    test -f "$out/share/applications/magpie.desktop"
    runHook postInstallCheck
  '';
})
