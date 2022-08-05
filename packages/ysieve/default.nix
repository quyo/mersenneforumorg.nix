{ stdenv, fetchFromGitHub, gmp, ytools }:

let
  pname = "ysieve";
  version = "0.20210916." + builtins.substring 0 8 commit;
  commit = "275fb23f05fd870f3b3afba00c8dbe63994b434f";
in

stdenv.mkDerivation {
  inherit pname version;
  inherit gmp ytools;

  src = fetchFromGitHub {
    owner = "bbuhrow";
    repo = "ysieve";
    rev = commit;
    sha256 = "k+j1Cs+TPnXCnYolgpMibFrXECjMLrmGm8AUGUooGpk=";
  };

  buildInputs = [ gmp ytools ];

  makeFlags = [ "COMPILER=gcc" "USE_AVX2=1" ];

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin     -m755 ysieve
    install -Dt $out/include -m644 soe.h
    install -Dt $out/lib     -m644 libysieve.a

    runHook postInstall
  '';
}
