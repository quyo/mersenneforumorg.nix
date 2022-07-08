{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    {
      overlay = import ./overlay.nix;
    }
    //
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlay
            devshell.overlay
          ];
        };

      in {

        packages = with pkgs; {
          inherit gmp ecm-git;
          inherit msieve-svn ytools ysieve yafu ggnfs;
          inherit ecmpy factmsievepy aliqueit;
          inherit cado-nfs;
          inherit primesieve primecount primesum;
        };

        devShell = with pkgs.devshell; mkShell {
          imports = [ (importTOML ./devshell.toml) ];
        };

      }
    );

}
