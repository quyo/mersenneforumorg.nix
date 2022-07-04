{ stdenv, fetchgit, gmp, ecm, ecmpy, yafu, msieve, factmsievepy, bash }:

let
  name = "${pname}-${version}";
  pname = "aliqueit";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "1c97023777735dd81200ad6f36ca9a8d1865f879";
in

assert gmp == ecm.gmp;
assert gmp == yafu.gmp;
assert gmp == msieve.gmp;
assert ecm == ecmpy.ecm;
assert ecm == yafu.ecm;
assert ecm == msieve.ecm;
assert msieve == yafu.msieve;
assert msieve == factmsievepy.msieve;

stdenv.mkDerivation {
  inherit name gmp ecm ecmpy yafu msieve factmsievepy;

  src = fetchgit {
    url = "https://github.com/ChristianBeer/aliqueit.git";
    rev = commit;
    sha256 = "pKDklTKAigZRi9O1/65ynxPW7d3piI0wQIGdvuolVco=";
  };

  buildInputs = [ gmp ecm ecmpy yafu msieve factmsievepy bash ];

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
    sed -i -e 's|^yafu_cmd = .*$|yafu_cmd = ${yafu}/bin/yafu-wrapped|'              aliqueit.ini
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

    mkdir -p $out/bin

    cp aliqueit.ini $out/bin/
    cp aliqueit.txt $out/bin/
    cp src/aliqueit $out/bin/aliqueit-wrapped

    cat > $out/bin/aliqueit <<'EOF'
    #!${bash}/bin/bash
    WORKDIR=$(mktemp -d)
    pushd $WORKDIR
    cp /out/bin/aliqueit-wrapped ./aliqueit
    cp /out/bin/aliqueit.ini .
    cp /out/bin/aliqueit.txt .
    cp ${yafu}/bin/yafu.ini .
    chmod +w ./*
    ./aliqueit "$@"
    popd
    rm -rfI $WORKDIR
    EOF

    sed -i -e "s|/out/|$out/|g" $out/bin/aliqueit
    chmod +x $out/bin/aliqueit

    runHook postInstall
  '';
}
