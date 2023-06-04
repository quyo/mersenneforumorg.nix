self: final: prev:

let
  inherit (prev) lib stdenv;
  inherit (final.lib.q) dontCheck dontInstallCheck dontCheckHaskell fixllvmPackages ignoreKnownVulnerabilities;
in

{
  python2 = ignoreKnownVulnerabilities prev.python2;
}
  // lib.optionalAttrs stdenv.hostPlatform.isAarch32
  { }
