{ stdenv, fetchgit, cmake, bash, gmp, ecm, python3, perl }:

let
  name = "${pname}-${version}";
  pname = "cado-nfs";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "9044db91bbb2cc853f27b166862077c8ce8e8686";
in

assert gmp == ecm.gmp;

stdenv.mkDerivation {
  inherit name gmp ecm;

  src = fetchgit {
    url = "https://gitlab.inria.fr/cado-nfs/cado-nfs";
    rev = commit;
    sha256 = "8swSRywCayZTFcvJYf5A3bR4ZjJNtRTlSTCaVj9i+nI=";
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
