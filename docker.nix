pkgs:

let

  contents = with pkgs; [
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

pkgs.dockerTools.buildLayeredImage {
  name = "quyo/mersenneforumorg.nix";
  tag = "latest";

  inherit contents;

  config = {
    Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
  };
}
