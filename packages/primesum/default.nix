{ stdenv, fetchgit, cmake }:

let
  name = "${pname}-${version}";
  pname = "primesum";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "ac22b966a560a42c1872c02beb8ac4d00d8d88d4";
in

stdenv.mkDerivation {
  inherit name;

  src = fetchgit {
    url = "https://github.com/kimwalisch/primesum";
    rev = commit;
    sha256 = "ctCEzgq25ikOdEC2erGqqYj+MTmotsvOZQrLYJb4Res=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = "-DBUILD_TESTS=ON";

  doCheck = true;

  checkPhase = ''
    ctest
  '';
}
