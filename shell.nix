{ pkgs }:

pkgs.mkShell {

  buildInputs = with pkgs.mersenneforumorg-flake; [
    aliqueit
    cado-nfs
    ecm-git
    ecmpy
    factmsievepy
    ggnfs
    msieve-svn
    primecount
    primesieve
    primesum
    yafu
    ysieve
  ];

# NIXSHELL_GREETING = "Hello, shell!";
#
# shellHook =
# ''
#   echo $NIXSHELL_GREETING
# '';

}
