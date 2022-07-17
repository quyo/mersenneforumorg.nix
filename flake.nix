{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
    {
      overlays = {
        default = import ./overlay.nix;
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
            gmp ecm-git
            msieve-svn ggnfs ytools ysieve yafu yafu-unwrapped
            ecmpy factmsievepy aliqueit aliqueit-unwrapped
            cado-nfs
            primesieve primecount primesum;
        };

      in {

        packages = flakePkgs
          //
          {
            default = pkgs.linkFarmFromDrvs "mersenneforumorg-packages-default" (map (x: flakePkgs.${x}) (builtins.attrNames flakePkgs));

            ci-build = self.packages.${system}.default.overrideAttrs (oldAttrs: { name = "mersenneforumorg-packages-ci-build"; });
            ci-publish = self.packages.${system}.default.overrideAttrs (oldAttrs: { name = "mersenneforumorg-packages-ci-publish"; });

            docker = (import ./docker.nix pkgs).overrideAttrs (oldAttrs: { name = "mersenneforumorg-packages-docker"; });
          };

        apps = import ./apps.nix pkgs;

        devShells = {
          default = with pkgs.devshell; mkShell {
            imports = [ (importTOML ./devshell.toml) ];
          };
        };

      }
    );

}
