{ stdenv, yafu-unwrapped, aliqueit-unwrapped, bash }:

let
  pname = "aliqueit";
  version = aliqueit-unwrapped.version;
in

assert yafu-unwrapped == aliqueit-unwrapped.yafu-unwrapped;

stdenv.mkDerivation {
  inherit pname version;
  inherit yafu-unwrapped aliqueit-unwrapped;

  buildInputs = [ yafu-unwrapped aliqueit-unwrapped bash ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cat > $out/bin/aliqueit <<'EOF'
    #!${bash}/bin/bash
    WORKDIR=$(mktemp -d)
    pushd $WORKDIR
    cp ${aliqueit-unwrapped}/bin/aliqueit .
    cp ${aliqueit-unwrapped}/bin/aliqueit.ini .
    cp ${aliqueit-unwrapped}/bin/aliqueit.txt .
    cp ${yafu-unwrapped}/bin/yafu.ini .
    chmod +w ./*
    ./aliqueit "$@"
    popd
    rm -rfI $WORKDIR
    EOF

    chmod +x $out/bin/aliqueit

    runHook postInstall
  '';
}
