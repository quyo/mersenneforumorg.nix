{ stdenv, fetchgit, cmake, bash, gmp, ecm, python3, perl }:

assert gmp == ecm.gmp;

let
  pname = "cado-nfs";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "f3a13e8a2c9b65d1853cb1205c58efe72954d1e5";
in

stdenv.mkDerivation {
  inherit pname version;
  inherit gmp ecm;

  src = fetchgit {
    url = "https://gitlab.inria.fr/cado-nfs/cado-nfs";
    rev = commit;
    sha256 = "jrV1nozmtwkM/4otq00NQYT3zbkzgzEF6WTRz76JBOg=";
  };

  nativeBuildInputs = [ cmake bash ];
  buildInputs = [ gmp ecm python3 perl ];

  patchPhase = ''
    runHook prePatch

    find . -type f -name "*.sh"    -exec sed -i -e 's|^#!/usr/bin/env bash$|#!${bash}/bin/bash|g' {} +
    find . -type f -name "*.pl"    -exec sed -i -e 's|^#!/usr/bin/env perl$|#!${perl}/bin/perl|g' {} +
    find . -type f -name "*.pl.in" -exec sed -i -e 's|^#!/usr/bin/env perl$|#!${perl}/bin/perl|g' {} +
    find . -type f -name "*.py"    -exec sed -i -e 's|^#!/usr/bin/env python3$|#!${python3}/bin/python3|g' {} +

    runHook postPatch
  '';

  configurePhase = ''
    runHook preConfigure

    cp local.sh.example local.sh
    echo >> local.sh
    echo "PREFIX=$out" >> local.sh

    runHook postConfigure
  '';
}
