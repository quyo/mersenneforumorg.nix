{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    {
      overlays = {
        default = import ./overlay.nix;
      };
    }
    //
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let

        pkgs = import nixpkgs {
          inherit system;
          overlays = (builtins.attrValues self.overlays) ++ [
            devshell.overlay
          ];
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
