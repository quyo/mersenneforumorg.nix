let
  lock = with (builtins); fromJSON (readFile ./flake.lock);

  inherit (lock.nodes.flake-compat.locked) narHash rev;

  compatSrc = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${rev}.tar.gz";
    sha256 = narHash;
  };
  compat = import compatSrc { src = ./.; };
in

compat.defaultNix
