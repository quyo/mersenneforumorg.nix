{ stdenv, unzip, ecm, python2 }:

let
  name = "${pname}-${version}";
  pname = "ecmpy";
  version = "0.44";
in

stdenv.mkDerivation {
  inherit name ecm;

  src = ./ecm-py_v0.44.zip;

  nativeBuildInputs = [ unzip ];
  buildInputs = [ ecm python2 ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src
    chmod +x ecm.py

    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    sed -i -e '1s|^|#!${python2}/bin/python2\n|'                ecm.py
    sed -i -e "s|^ECM_PATH = .*$|ECM_PATH = '${ecm}/bin'|"      ecm.py
    sed -i -e 's|^ECM_THREADS = .*$|ECM_THREADS = 4|'           ecm.py

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ecm.py $out/bin/

    runHook postInstall
  '';
}
