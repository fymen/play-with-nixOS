{ stdenv, fetchzip }:
stdenv.mkDerivation {
  pname = "pilish-markdown-grammars";
  version = "0.4.1-pilish.2";
  # Emacs 30 needs ABI 14. This backport includes the Markdown scanner fixes.
  src = fetchzip {
    url = "https://github.com/dnouri/tree-sitter-markdown/archive/refs/tags/v0.4.1-pilish.2.tar.gz";
    hash = "sha256-aWUXEdqrNKSiNCmSctlqp5bhavczd0ttAw9+R5Z+UZE=";
  };
  buildPhase = ''
    runHook preBuild
    for grammar in markdown markdown-inline; do
      dir="tree-sitter-$grammar/src"
      $CC -shared -fPIC -O2 -I"$dir" \
        "$dir/parser.c" "$dir/scanner.c" -o "libtree-sitter-$grammar.so"
    done
    runHook postBuild
  '';
  installPhase = ''
    mkdir -p $out/lib
    cp libtree-sitter-*.so $out/lib/
  '';
}
