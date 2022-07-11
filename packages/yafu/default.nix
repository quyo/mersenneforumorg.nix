{ stdenv, yafu-unwrapped, bash }:

let
  pname = "yafu";
  version = yafu-unwrapped.version;
in

stdenv.mkDerivation {
  inherit pname version;
  inherit yafu-unwrapped;

  buildInputs = [ yafu-unwrapped bash ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cat > $out/bin/yafu <<'EOF'
    #!${bash}/bin/bash
    WORKDIR=$(mktemp -d)
    pushd $WORKDIR
    cp ${yafu-unwrapped}/bin/yafu .
    cp ${yafu-unwrapped}/bin/yafu.ini .
    chmod +w ./*
    ./yafu "$@"
    popd
    rm -rfI $WORKDIR
    EOF

    chmod +x $out/bin/yafu

    runHook postInstall
  '';
}
