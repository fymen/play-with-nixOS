{ trivialBuild, fetchzip, transient, magit-section, md-ts-mode, markdown-table-wrap }:
trivialBuild {
  pname = "pilish";
  version = "3.4.5";
  src = fetchzip {
    url = "https://github.com/dnouri/pilish/archive/69179108707fd056885707314404efc6d0cf8d2e.tar.gz";
    hash = "sha256-J9vc/kSEgOcaUKuWBwoOqmF0nN1PD18zxl56ANSQ4dU=";
  };
  packageRequires = [ transient magit-section md-ts-mode markdown-table-wrap ];
}
