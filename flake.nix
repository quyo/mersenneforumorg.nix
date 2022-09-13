{
  inputs = {
    # nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/a28adc36c20fd2fbaeb06ec9bbd79b6bf7443979";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/0e304ff0d9db453a4b230e9386418fd974d5804a";

    flake-utils.url = "github:numtide/flake-utils";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs-stable";
    devshell.inputs.flake-utils.follows = "flake-utils";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    qnixpkgs.url = "github:Samayel/qnixpkgs";
    qnixpkgs.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    qnixpkgs.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    qnixpkgs.inputs.flake-utils.follows = "flake-utils";
    qnixpkgs.inputs.devshell.follows = "devshell";
    qnixpkgs.inputs.flake-compat.follows = "flake-compat";
    qnixpkgs.inputs.qnixpkgs.follows = "qnixpkgs";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, flake-utils, devshell, qnixpkgs, ... }:
    {
      overlays = {
        default = import ./overlay.nix self;
      };
    }
    //
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let
        inherit (pkgs-stable) lib;

        version = lib.q.flake.version self;

        overlays = (builtins.attrValues self.overlays) ++ [
          devshell.overlay
          qnixpkgs.overlays.lib
          qnixpkgs.overlays.qshell
        ];

        pkgs-stable = import nixpkgs-stable { inherit overlays system; };
        pkgs-unstable = import nixpkgs-unstable { inherit overlays system; };

        flake-pkgs-mapper = lib.q.mapPkgs
          [
            "aliqueit"
            "aliqueit-unwrapped"
            "cado-nfs"
            "ecm-git"
            "ecmpy"
            "factmsievepy"
            "ggnfs"
            "mersenneforumorg"
            "msieve-nfsathome"
            # "msieve-svn"
            # "primecount"
            # "primesieve"
            # "primesum"
            "yafu"
            "yafu-unwrapped"
            "ysieve"
            "ytools"
          ];

        flake-pkgs = flake-pkgs-mapper pkgs-stable "" "";
      in
      {
        packages = lib.q.flake.packages "mersenneforumorg" version flake-pkgs { } ./docker.nix;

        apps = lib.q.flake.apps flake-pkgs ./apps.nix;

        devShells = lib.q.flake.devShells ./devshell.toml;

        formatter = lib.q.flake.formatter;
      }
    );
}
