{ bashInteractive
, dockerTools
, mersenneforumorg
, qshell-minimal
}:

let
  contents = [
    mersenneforumorg
    qshell-minimal
  ];
in

dockerTools.buildLayeredImage {
  name = "quyo/mersenneforumorg.nix";
  tag = "latest";

  inherit contents;

  config = {
    Cmd = [ "${bashInteractive}/bin/bash" ];
  };
}
