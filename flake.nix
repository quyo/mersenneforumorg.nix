{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, devshell }:
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
          inherit (pkgs) gmp ecm-git;
          inherit (pkgs) msieve-svn ytools ysieve yafu ggnfs;
          inherit (pkgs) ecmpy factmsievepy aliqueit;
          inherit (pkgs) cado-nfs;
          inherit (pkgs) primesieve primecount primesum;
        };

      in {

        packages = flakePkgs
          //
          {
            default = pkgs.linkFarmFromDrvs "mersenneforumorg-packages-all" (map (x: flakePkgs.${x}) (builtins.attrNames flakePkgs));
          };

        apps = import ./apps.nix self system;

        devShells = {
          default = with pkgs.devshell; mkShell {
            imports = [ (importTOML ./devshell.toml) ];
          };
        };

      }
    );

}
