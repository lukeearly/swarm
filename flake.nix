{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    (import ./. {
      inherit flake-utils;
      my-nixpkgs = nixpkgs;
    }) // rec {
      templates = import ./templates/default.nix;
      defaultTemplate = templates.empty;
    };
}