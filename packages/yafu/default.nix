{ writeShellApplication, coreutils, yafu-unwrapped }:

let
  pname = "yafu";
  version = yafu-unwrapped.version;

  app = writeShellApplication {
    name = pname;

    runtimeInputs = [ coreutils ];

    text = ''
      WORKDIR=$(mktemp -d)
      pushd "$WORKDIR"

      cp ${yafu-unwrapped}/bin/yafu .
      cp ${yafu-unwrapped}/bin/yafu.ini .
      chmod +w ./*
      ./yafu "$@"

      popd
      rm -rfI "$WORKDIR"
    '';
  };
in

app.overrideAttrs (oldAttrs: {
  inherit pname version;
  name = "${pname}-${version}";
})
