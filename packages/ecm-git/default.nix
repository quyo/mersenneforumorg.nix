{ lib, stdenv, fetchgit, autoreconfHook, m4, gmp }:

let
  pname = "ecm";
  version = "0.20220826." + builtins.substring 0 8 commit;
  commit = "1ae5403108addaef7e1b74e181f17e8fb276097a";
in

stdenv.mkDerivation {
  inherit pname version;
  inherit gmp;

  src = fetchgit {
    url = "https://gitlab.inria.fr/zimmerma/ecm";
    rev = commit;
    sha256 = "LP+2UOIAjbJ3H9J7csY3jfxxK7yA0iGRw5sJlLSPJpo=";
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
