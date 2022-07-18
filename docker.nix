{
  aliqueit,
  bashInteractive,
  cado-nfs,
  dockerTools,
  ecm-git,
  msieve-svn,
  primecount,
  primesieve,
  primesum,
  qshell-minimal,
  yafu
}:

let

  contents = [
    qshell-minimal

    aliqueit
    cado-nfs
    ecm-git
    msieve-svn
    primecount
    primesieve
    primesum
    yafu
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
