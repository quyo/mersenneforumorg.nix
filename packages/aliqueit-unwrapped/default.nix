{ stdenv, fetchgit, gmp, ecm, ecmpy, yafu-unwrapped, msieve, factmsievepy }:

let
  pname = "aliqueit-unwrapped";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "1c97023777735dd81200ad6f36ca9a8d1865f879";
in

assert gmp == ecm.gmp;
assert gmp == yafu-unwrapped.gmp;
assert gmp == msieve.gmp;
assert ecm == ecmpy.ecm;
assert ecm == yafu-unwrapped.ecm;
assert ecm == msieve.ecm;
assert msieve == yafu-unwrapped.msieve;
assert msieve == factmsievepy.msieve;

stdenv.mkDerivation {
  inherit pname version;
  inherit gmp ecm ecmpy yafu-unwrapped msieve factmsievepy;

  src = fetchgit {
    url = "https://github.com/ChristianBeer/aliqueit.git";
    rev = commit;
    sha256 = "pKDklTKAigZRi9O1/65ynxPW7d3piI0wQIGdvuolVco=";
  };

  buildInputs = [ gmp ecm ecmpy yafu-unwrapped msieve factmsievepy ];

  b2scalepatch = ./b2scale.patch;

  patchPhase = ''
    runHook prePatch

    cat $b2scalepatch | patch -p1 --

    sed -i -e 's|system((cfg.ggnfs_cmd + " " + dir + "/test").c_str());|system((cfg.ggnfs_cmd + " test").c_str());|' src/aliqueit.cc

    sed -i -e 's|^\(ggnfs_clean_cmd = del\)|//\1|'                                  aliqueit.ini
    sed -i -e 's|^//\(ggnfs_clean_cmd = rm\)|\1|'                                   aliqueit.ini
    sed -i -e 's|^\(null_device = nul\)|//\1|'                                      aliqueit.ini
    sed -i -e 's|^//\(null_device = /dev\)|\1|'                                     aliqueit.ini
    sed -i -e 's|^ecm_cmd = .*$|ecm_cmd = ${ecm}/bin/ecm|'                          aliqueit.ini
    sed -i -e 's|^ecmpy_cmd = .*$|ecmpy_cmd = ${ecmpy}/bin/ecm.py|'                 aliqueit.ini
    sed -i -e 's|^yafu_cmd = .*$|yafu_cmd = ${yafu-unwrapped}/bin/yafu|'            aliqueit.ini
    sed -i -e 's|^msieve_cmd = .*$|msieve_cmd = ${msieve}/bin/msieve|'              aliqueit.ini
    sed -i -e 's|^ggnfs_cmd = .*$|ggnfs_cmd = ${factmsievepy}/bin/factmsieve.py|'   aliqueit.ini
    sed -i -e 's|^stop_on_failure = .*$|stop_on_failure = true|'                    aliqueit.ini
    sed -i -e 's|^prefer_yafu = .*$|prefer_yafu = true|'                            aliqueit.ini
    sed -i -e 's|^use_ecmpy = .*$|use_ecmpy = true|'                                aliqueit.ini
    sed -i -e 's|^gnfs_cutoff = .*$|gnfs_cutoff = 95|'                              aliqueit.ini

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    cd src
    make
    cd ..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin -m755 src/aliqueit
    install -Dt $out/bin -m644 aliqueit.ini
    install -Dt $out/bin -m644 aliqueit.txt

    runHook postInstall
  '';
}
