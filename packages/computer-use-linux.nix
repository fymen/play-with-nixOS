{
  lib, rustPlatform, fetchFromGitHub, makeWrapper,
  bash, coreutils, dbus, glib, hyprland, procps, systemd, which,
  wl-clipboard, wtype, writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage rec {
  pname = "computer-use-linux";
  version = "0.7.59";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${version}";
    hash = "sha256-o7wSofaNOf8XOEcvlN3q3lelVZ7ggHMqmnj0KmsBWEk=";
  };
  cargoHash = "sha256-oE3YKIcH0dhuA10cp+WFA6rCZiJHi7Vrf8Hg4C8qE50=";

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ dbus writableTmpDirAsHomeHook ];

  # Runtime shell execution and the isolated test fixtures use FHS paths upstream.
  postPatch = ''
    while IFS= read -r -d "" path; do
      substituteInPlace "$path" \
        --replace-quiet '/bin/sh' '${bash}/bin/sh' \
        --replace-quiet '/bin/cat' '${coreutils}/bin/cat' \
        --replace-quiet '/bin/cp' '${coreutils}/bin/cp' \
        --replace-quiet '/bin/false' '${coreutils}/bin/false' \
        --replace-quiet '/bin/sleep' '${coreutils}/bin/sleep' \
        --replace-quiet '/bin/true' '${coreutils}/bin/true' \
        --replace-quiet 'Command::new("dbus-daemon")' 'Command::new("${dbus}/bin/dbus-daemon")'
    done < <(find src -name '*.rs' -print0)
  '';

  # Install the CLI only, not the GNOME extension or COSMIC/indicator helpers.
  cargoBuildFlags = [ "--bin" "computer-use-linux" ];
  cargoTestFlags = [ "--lib" ];
  # These two tests require a root-owned sticky /tmp outside Nix's sandbox.
  # Do not weaken the production socket ownership checks to accommodate them.
  checkFlags = [
    "--skip=server::tests::pointer_coordinate_backend_dispatch_is_safe"
    "--skip=server::tests::untargeted_scroll_keeps_portal_start_error"
  ];

  postInstall = ''
    wrapProgram "$out/bin/computer-use-linux" \
      --suffix PATH : ${lib.makeBinPath [ coreutils glib hyprland procps systemd which wl-clipboard wtype ]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    # This upstream CLI has no --version flag; Nix carries the pinned version.
    "$out/bin/computer-use-linux" --help > /dev/null
    "$out/bin/computer-use-linux" doctor --help > /dev/null
    "$out/bin/computer-use-linux" mcp --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Native Linux desktop observation and control CLI with an optional MCP server";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "computer-use-linux";
  };
}
