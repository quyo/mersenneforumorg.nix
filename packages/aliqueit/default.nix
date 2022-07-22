{ writeShellApplication, coreutils, yafu-unwrapped, aliqueit-unwrapped }:

assert yafu-unwrapped == aliqueit-unwrapped.yafu-unwrapped;

let
  pname = "aliqueit";
  version = aliqueit-unwrapped.version;

  app = writeShellApplication {
    name = pname;

    runtimeInputs = [ coreutils ];

    text = ''
      WORKDIR=$(mktemp -d)
      pushd "$WORKDIR"

      cp ${aliqueit-unwrapped}/bin/aliqueit .
      cp ${aliqueit-unwrapped}/bin/aliqueit.ini .
      cp ${aliqueit-unwrapped}/bin/aliqueit.txt .
      cp ${yafu-unwrapped}/bin/yafu.ini .
      chmod +w ./*
      ./aliqueit "$@"

      popd
      rm -rfI "$WORKDIR"
    '';
  };
in

app.overrideAttrs (oldAttrs: {
  inherit pname version;
  name = "${pname}-${version}";
})
