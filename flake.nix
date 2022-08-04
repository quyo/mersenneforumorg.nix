{
  inputs = {
    # nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/d4f600ec45d9a14d41a4d5a61c034fa1bd819f88";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/f4a4245e55660d0a590c17bab40ed08a1d010787";

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
        inherit (pkgs-stable) lib linkFarmFromDrvs;
        inherit (pkgs-stable.devshell) importTOML mkShell;

        version = lib.q.flakeVersion self;

        overlays = (builtins.attrValues self.overlays) ++ [
          devshell.overlay
          qnixpkgs.overlays.lib
          qnixpkgs.overlays.qshell
        ];

        pkgs-stable = import nixpkgs-stable { inherit overlays system; };
        pkgs-unstable = import nixpkgs-unstable { inherit overlays system; };

        flake-pkgs = {
          inherit (pkgs-stable)
            ecm-git msieve-svn ggnfs ytools ysieve yafu yafu-unwrapped
            ecmpy factmsievepy aliqueit aliqueit-unwrapped
            cado-nfs
            # primesieve primecount primesum
            mersenneforumorg;
        };
      in
      {
        packages = flake-pkgs //
        {
          default = linkFarmFromDrvs "mersenneforumorg-default-${version}" (builtins.attrValues flake-pkgs);

          ci-build = linkFarmFromDrvs "mersenneforumorg-ci-build-${version}" (builtins.attrValues flake-pkgs);
          ci-publish = linkFarmFromDrvs "mersenneforumorg-ci-publish-${version}" (builtins.attrValues flake-pkgs);

          docker = lib.q.overrideName (lib.callPackageWith (pkgs-stable // flake-pkgs) ./docker.nix { }) "mersenneforumorg-docker" version;
        };

        apps = lib.q.removeOverrideFuncs (lib.callPackageWith flake-pkgs ./apps.nix { });

        devShells = {
          default = mkShell { imports = [ (importTOML ./devshell.toml) ]; };
        };

        formatter = pkgs-stable.nixpkgs-fmt;
      }
    );
}
