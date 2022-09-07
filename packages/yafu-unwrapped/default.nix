{ stdenv, fetchFromGitHub, gmp, ecm, msieve, ytools, ysieve, ggnfs }:

assert gmp == ecm.gmp;
assert gmp == msieve.gmp;
assert gmp == ysieve.gmp;
assert gmp == ggnfs.gmp;
assert ecm == msieve.ecm;
assert ytools == ysieve.ytools;
assert null == msieve.zlib;

let
  pname = "yafu-unwrapped";
  version = "0.20220830." + builtins.substring 0 8 commit;
  commit = "2003671ed5cacac5efcbc21eb3b8b1edac26e9cb";
in

stdenv.mkDerivation {
  inherit pname version;
  inherit gmp ecm msieve ytools ysieve ggnfs;

  src = fetchFromGitHub {
    owner = "bbuhrow";
    repo = "yafu";
    rev = commit;
    sha256 = "ptARRTj+U9zH3x3KZfDbb1faEBiDBNHiNc+CpxH9GdI=";
  };

  buildInputs = [ gmp ecm msieve ytools ysieve ggnfs ];

  patchPhase = ''
    runHook prePatch

    sed -i -e 's| /users/buhrow/src/c/gmp_install/gmp-6.2.0/lib/libgmp.a | -lgmp |g' Makefile

    sed -i -e 's|^% threads=1$|threads=4|'                  yafu.ini
    sed -i -e 's|^% nprp=1$|nprp=20|'                       yafu.ini
    sed -i -e 's|^v$|% v|'                                  yafu.ini
    sed -i -e 's|^xover=.*$|xover=95|'                      yafu.ini
    sed -i -e 's|^ggnfs_dir=.*$|ggnfs_dir=${ggnfs}/bin/|'   yafu.ini
    sed -i -e 's|^ecm_path=.*$|ecm_path=${ecm}/bin/ecm|'    yafu.ini
    sed -i -e 's|^ext_ecm=.*$|ext_ecm=10000|'               yafu.ini

    runHook postPatch
  '';

  makeFlags = [ "COMPILER=gcc" "NFS=1" "USE_SSE41=1" "USE_AVX2=1" "USE_BMI2=1" ];

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin -m755 yafu
    install -Dt $out/bin -m644 yafu.ini

    runHook postInstall
  '';
}
