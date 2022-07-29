{
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs.url = "github:nixos/nixpkgs/d4f600ec45d9a14d41a4d5a61c034fa1bd819f88";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/f4a4245e55660d0a590c17bab40ed08a1d010787";

    flake-utils.url = "github:numtide/flake-utils";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    qnixpkgs.url = "github:Samayel/qnixpkgs";
    qnixpkgs.inputs.nixpkgs.follows = "nixpkgs";
    qnixpkgs.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    qnixpkgs.inputs.flake-utils.follows = "flake-utils";
    qnixpkgs.inputs.devshell.follows = "devshell";
    qnixpkgs.inputs.flake-compat.follows = "flake-compat";
    qnixpkgs.inputs.qnixpkgs.follows = "qnixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, devshell, qnixpkgs, ... }:
    let
      version =
        let
          inherit (builtins) substring;
          inherit (self) lastModifiedDate;
        in
        "0.${substring 0 8 lastModifiedDate}.${substring 8 6 lastModifiedDate}.${self.shortRev or "dirty"}";
    in
    {
      overlays = {
        default = import ./overlay.nix version;
      };
    }
    //
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let
        flakeOverlays = (builtins.attrValues self.overlays) ++ [
          devshell.overlay
          qnixpkgs.overlays.qshell
        ];

        # can now use "pkgs.package" or "pkgs.unstable.package"
        unstableOverlay = final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            overlays = flakeOverlays;
          };
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ unstableOverlay ] ++ flakeOverlays;
        };

        flakePkgs = {
          inherit (pkgs)
            ecm-git msieve-svn ggnfs ytools ysieve yafu yafu-unwrapped
            ecmpy factmsievepy aliqueit aliqueit-unwrapped
            cado-nfs
            # primesieve primecount primesum
            mersenneforumorg;
        };

        callPackage = pkgs.lib.callPackageWith (pkgs // flakePkgs);
        callPackageNonOverridable = fn: args: removeAttrs (callPackage fn args) [ "override" "overrideDerivation" ];
      in
      {
        packages = flakePkgs
        //
        {
          default = pkgs.linkFarmFromDrvs "mersenneforumorg-default-${version}" (map (x: flakePkgs.${x}) (builtins.attrNames flakePkgs));

          ci-build = self.packages.${system}.default.overrideAttrs (oldAttrs: { name = "mersenneforumorg-ci-build-${version}"; });
          ci-publish = self.packages.${system}.default.overrideAttrs (oldAttrs: { name = "mersenneforumorg-ci-publish-${version}"; });

          docker = (callPackage ./docker.nix { }).overrideAttrs (oldAttrs: { name = "mersenneforumorg-docker-${version}"; });
        };

        apps = callPackageNonOverridable ./apps.nix { };

        devShells = {
          default =
            let
              inherit (pkgs.devshell) mkShell importTOML;
            in
            mkShell {
              imports = [ (importTOML ./devshell.toml) ];
            };
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
