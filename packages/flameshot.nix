{ pkgs, ...}:
# It worked, but no icons in the work area. Waiting for the next stable version.
with pkgs;
stdenv.mkDerivation rec {
  name = "flameshot";

  src = fetchFromGitHub {
    owner = "flameshot-org";
    repo = "flameshot";
    rev = "fa29bcb";
    sha256 = "0d56xccfx4c7g5qk2kb43ngjnwp8ay760n8ds6b8lavkmfnsx2jw";
  };


  nativeBuildInputs = [ git cmake libsForQt5.qt5.qttools libsForQt5.qt5.qtsvg hicolor-icon-theme ];
  buildInputs = [ libsForQt5.qt5.qtbase libsForQt5.kguiaddons hicolor-icon-theme ];

  dontWrapQtApps = true;
  enableParallelBuilding = true;

  cmakeFlags = [
    "-DUSE_WAYLAND_CLIPBOARD=1"
    "-DUSE_WAYLAND_GRIM=true"
  ];

  meta = with lib; {
    description = "Powerful yet simple to use screenshot software";
    homepage = "https://github.com/flameshot-org/flameshot";
    mainProgram = "flameshot";
    maintainers = with maintainers; [ scode oxalica ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
