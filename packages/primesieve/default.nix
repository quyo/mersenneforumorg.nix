{ stdenv, fetchgit, cmake }:

let
  name = "${pname}-${version}";
  pname = "primesieve";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "6b13e217df6932f4714048cead12579fc34e1d32";
in

stdenv.mkDerivation {
  inherit name;

  src = fetchgit {
    url = "https://github.com/kimwalisch/primesieve";
    rev = commit;
    sha256 = "sqHNQXWeo+Iktq3gyiDLblBq/9QNlUQDvi1oHcZ2XYM=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = "-DBUILD_TESTS=ON";

  doCheck = false;

  checkPhase = ''
    ctest
  '';
}
