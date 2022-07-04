{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "mersenneforumorg-flake";
      config = { };
      overlay = ./overlay.nix;
      shell = ./shell.nix;
    };
}
