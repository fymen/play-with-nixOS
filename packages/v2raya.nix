{ lib, stdenvNoCC, fetchurl, makeWrapper, v2ray-geoip, v2ray-domain-list-community, v2ray ? null }:
let
  version = "2.5.16";
  server = fetchurl {
    url = "https://github.com/v2rayA/v2rayA/releases/download/v${version}/v2raya_linux_x64_${version}";
    hash = "sha256-YmqHuj+8yyaIUp3758h4FnHiZD5N7S0H4uDIAN+GPCw=";
  };
  core = fetchurl {
    url = "https://github.com/v2rayA/v2rayA/releases/download/v${version}/v2raya_core_linux_x64_${version}";
    hash = "sha256-ae3yEAXCmCVKInaSN+g0OLIrHvAB5VMuSnQ5bQ5LnZ0=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "v2raya";
  inherit version;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    install -Dm755 ${server} $out/bin/v2rayA
    install -Dm755 ${core} $out/bin/v2raya_core
    mkdir -p $out/share/v2ray
    ln -s ${v2ray-geoip}/share/v2ray/geoip.dat $out/share/v2ray/geoip.dat
    ln -s ${v2ray-domain-list-community}/share/v2ray/geosite.dat $out/share/v2ray/geosite.dat
    wrapProgram $out/bin/v2rayA \
      --set V2RAYA_V2RAY_BIN $out/bin/v2raya_core \
      --set V2RAYA_V2RAY_ASSETSDIR $out/share/v2ray
    runHook postInstall
  '';
  meta = {
    description = "v2rayA with its matching bundled core (official release binaries)";
    homepage = "https://github.com/v2rayA/v2rayA";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "v2rayA";
  };
}
