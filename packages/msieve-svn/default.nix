{ lib, stdenv, fetchsvn, subversion, zlib, gmp, ecm }:

let
  pname = "msieve";
  version = "svn-" + revision;
  revision = "1044";
in

assert gmp == ecm.gmp;

stdenv.mkDerivation {
  inherit pname version;
  inherit zlib gmp ecm;

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/msieve/code/trunk/";
    rev = revision;
    sha256 = "njutwl3z09yK4oahFYHpLrKGpVSoJqUxFeuou4zeQWU=";
  };

  nativeBuildInputs = [ subversion ];
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

  meta = {
    description = "A C library implementing a suite of algorithms to factor large integers";
    license = lib.licenses.publicDomain;
    homepage = "http://msieve.sourceforge.net/";
    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
  };
}
