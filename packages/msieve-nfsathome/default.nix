{ lib, stdenv, fetchFromGitHub, zlib, gmp, ecm }:

assert gmp == ecm.gmp;

let
  pname = "msieve-nfsathome";
  version = "0.20220831." + builtins.substring 0 8 commit;
  # branch "try_openmp"
  commit = "81e4aa3892f3f639ac5cb1bc9e1077c53c45810b";
in

stdenv.mkDerivation {
  inherit pname version;
  inherit zlib gmp ecm;

  src = fetchFromGitHub {
    owner = "gchilders";
    repo = "msieve_nfsathome";
    rev = commit;
    sha256 = "+S4LgyASspLXccZDlzkFGKd1QNBDUQ1e5rFX5DKnD/w=";
  };

  buildInputs = [ zlib gmp ecm ];

  ECM = if ecm == null then "0" else "1";
  NO_ZLIB = if zlib == null then "1" else "0";

  # Doesn't hurt Linux but lets clang-based platforms like Darwin work fine too
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "all" ];

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin     -m755 msieve
    install -Dt $out/include -m644 include/msieve.h
    install -Dt $out/include -m644 zlib/zconf.h
    install -Dt $out/include -m644 zlib/zlib.h
    install -Dt $out/lib     -m644 libmsieve.a

    runHook postInstall
  '';
}
