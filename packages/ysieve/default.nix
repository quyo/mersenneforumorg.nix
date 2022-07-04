{ stdenv, fetchgit, gmp, ytools }:

let
  name = "${pname}-${version}";
  pname = "ysieve";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "275fb23f05fd870f3b3afba00c8dbe63994b434f";
in

stdenv.mkDerivation {
  inherit name gmp ytools;

  src = fetchgit {
    url = "https://github.com/bbuhrow/ysieve";
    rev = commit;
    sha256 = "k+j1Cs+TPnXCnYolgpMibFrXECjMLrmGm8AUGUooGpk=";
  };

  buildInputs = [ gmp ytools ];

  makeFlags = [ "COMPILER=gcc" "USE_AVX2=1" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,include,lib}
    cp ysieve $out/bin/
    cp soe.h $out/include/
    cp libysieve.a $out/lib/

    runHook postInstall
  '';
}
