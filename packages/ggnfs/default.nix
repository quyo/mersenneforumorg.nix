{ stdenv, fetchgit, m4, gmp }:

let
  name = "${pname}-${version}";
  pname = "ggnfs";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "3490572ca8671635a1b8d13a28aef3e34a657fc7";
in

stdenv.mkDerivation {
  inherit name gmp;

  src = fetchgit {
    url = "https://github.com/radii/ggnfs";
    rev = commit;
    sha256 = "M8e6m4d25T+SJb3E/tbRTXL1RuhHupkxMiD04XEQ7kU=";
  };

  nativeBuildInputs = [ m4 ];
  buildInputs = [ gmp ];

  patches = [ ./make.patch ./c.patch ./asm.patch ];

  buildPhase = ''
    runHook preBuild

    make x86_64

    cd src/experimental/lasieve4_64/athlon64/
    make liblasieve.a
    make liblasieveI11.a
    make liblasieveI12.a
    make liblasieveI13.a
    make liblasieveI14.a
    make liblasieveI15.a
    make liblasieveI16.a
    cp *.a ../

    cd ../
    ln -s athlon64/ asm
    make
    cd ../../../

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/* $out/bin
    cp src/experimental/lasieve4_64/gnfs-lasieve4I1{1,2,3,4,5,6}e $out/bin/

    runHook postInstall
  '';
}
