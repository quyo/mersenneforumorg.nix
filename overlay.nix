final: prev:

let
  nixpkgs = prev;
  allPkgs = nixpkgs // pkgs;

  callPackage = path: overrides:
    let f = import path;
    in nixpkgs.lib.makeOverridable f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  pkgs = rec {
    gmp = nixpkgs.gmp;
    ecm-git = callPackage ./packages/ecm-git { };

    msieve-svn = callPackage ./packages/msieve-svn { ecm = ecm-git; zlib = null; };
    ytools = callPackage ./packages/ytools { };
    ysieve = callPackage ./packages/ysieve { };
    yafu = callPackage ./packages/yafu { ecm = ecm-git; msieve = msieve-svn; };
    ggnfs = callPackage ./packages/ggnfs { };
    ecmpy = callPackage ./packages/ecmpy { ecm = ecm-git; };
    factmsievepy = callPackage ./packages/factmsievepy { msieve = msieve-svn; };
    aliqueit = callPackage ./packages/aliqueit { ecm = ecm-git; msieve = msieve-svn; };

    cado-nfs = callPackage ./packages/cado-nfs { ecm = ecm-git; };

    primesieve = callPackage ./packages/primesieve { };
    primecount = callPackage ./packages/primecount { };
    primesum = callPackage ./packages/primesum { };
  };
in

{
  # this key should be the same as the flake name attribute.
  mersenneforumorg-flake = pkgs;
}
