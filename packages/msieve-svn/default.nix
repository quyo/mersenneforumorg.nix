{ lib, stdenv, fetchsvn, subversion, zlib, gmp, ecm }:

let
  name = "${pname}-${version}";
  pname = "msieve";
  version = "svn-" + revision;
  revision = "1044";
in

assert gmp == ecm.gmp;

stdenv.mkDerivation rec {
  inherit name zlib gmp ecm;

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

    mkdir -p $out/{bin,include,lib}
    cp msieve $out/bin/
    cp include/msieve.h $out/include/
    cp zlib/zconf.h $out/include/
    cp zlib/zlib.h $out/include/
    cp libmsieve.a $out/lib/

    runHook postInstall
  '';

  meta = {
    description = "A C library implementing a suite of algorithms to factor large integers";
    license = lib.licenses.publicDomain;
    homepage = "http://msieve.sourceforge.net/";
    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
  };
}
