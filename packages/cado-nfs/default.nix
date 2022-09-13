{ stdenv, fetchgit, cmake, bash, gmp, ecm, python3, perl }:

assert gmp == ecm.gmp;

let
  pname = "cado-nfs";
  version = "0.20220901." + builtins.substring 0 8 commit;
  commit = "aa5eabceff3c89e2e0e3536fce78fce0af33c31f";
in

stdenv.mkDerivation {
  inherit pname version;
  inherit gmp ecm;

  src = fetchgit {
    url = "https://gitlab.inria.fr/cado-nfs/cado-nfs";
    rev = commit;
    sha256 = "T05QegunVoC8nAXE0DqvFz4vTIUZQXJunXwKEjOMe4U=";
  };

  nativeBuildInputs = [ cmake bash ];
  buildInputs = [ gmp ecm python3 perl ];

  patchPhase = ''
    runHook prePatch

    find . -type f -name "*.sh"    -exec sed -i -e 's|^#!/usr/bin/env bash$|#!${bash}/bin/bash|g' {} +
    find . -type f -name "*.pl"    -exec sed -i -e 's|^#!/usr/bin/env perl$|#!${perl}/bin/perl|g' {} +
    find . -type f -name "*.pl.in" -exec sed -i -e 's|^#!/usr/bin/env perl$|#!${perl}/bin/perl|g' {} +
    find . -type f -name "*.py"    -exec sed -i -e 's|^#!/usr/bin/env python3$|#!${python3}/bin/python3|g' {} +

    # build and install convert_poly executable
    sed -i -e 's|^add_executable(convert_poly EXCLUDE_FROM_ALL convert_poly\.c)$|add_executable(convert_poly convert_poly.c)|' misc/CMakeLists-nodist.txt
    sed -i -e 's|^target_link_libraries(convert_poly utils)$|target_link_libraries(convert_poly utils)\ninstall(TARGETS convert_poly RUNTIME DESTINATION ''${LIBSUFFIX}/misc)|' misc/CMakeLists-nodist.txt

    runHook postPatch
  '';

  configurePhase = ''
    runHook preConfigure

    cp local.sh.example local.sh
    echo >> local.sh
    echo "PREFIX=$out" >> local.sh

    runHook postConfigure
  '';

  params = ./params;

  postInstall = "cp $params/* $out/share/cado-nfs-3.0.0/factor/";

}
