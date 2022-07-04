{ stdenv, fetchgit, cmake }:

let
  name = "${pname}-${version}";
  pname = "primecount";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "2439921b2cd656b396bc2cda24d9e3e177171f6f";
in

stdenv.mkDerivation {
  inherit name;

  src = fetchgit {
    url = "https://github.com/kimwalisch/primecount";
    rev = commit;
    sha256 = "0VJmYHbPlgMlio6zhHn2j1gW7CAaPBt1pWtEbnZGr7I=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = "-DBUILD_TESTS=ON";

  doCheck = true;

  checkPhase = ''
    ctest
  '';
}
