{ lib, stdenv, fetchgit, autoreconfHook, m4, gmp }:

let
  name = "${pname}-${version}";
  pname = "ecm";
  version = "git-" + builtins.substring 0 8 commit;
  commit = "5663e00cb4880a6ee6393eb9067e9eea201098d4";
in

stdenv.mkDerivation {
  inherit name gmp;

  src = fetchgit {
    url = "https://gitlab.inria.fr/zimmerma/ecm";
    rev = commit;
    sha256 = "JVmtB6gdLHWF6lHdW7RiWydx/KEEyIPHcNfb0w1lnec=";
  };

  nativeBuildInputs = [ autoreconfHook m4 ];
  buildInputs = [ gmp ];

  patchPhase = ''
    runHook prePatch

    sed -i -e 's|^/bin/rm |rm |g' test.*

    runHook postPatch
  '';

  # See https://trac.sagemath.org/ticket/19233
  configureFlags = lib.optional stdenv.isDarwin "--disable-asm-redc";

  doCheck = true;

  meta = {
    description = "Elliptic Curve Method for Integer Factorization";
    license = lib.licenses.gpl2Plus;
    homepage = "http://ecm.gforge.inria.fr/";
    platforms = with lib.platforms; linux ++ darwin;
  };
}
