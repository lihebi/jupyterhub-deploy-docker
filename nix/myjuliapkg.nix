{pkgs ? import <nixpkgs> {}}:

let
  julia-bin = pkgs.callPackage ./myjulia-bin.nix {};
in
  julia-bin
