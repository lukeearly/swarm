{ flake-utils, my-nixpkgs }:

with my-nixpkgs.lib;

let
  baseUtils = import ./base-utils.nix { inherit (my-nixpkgs) lib; };
  inherit (baseUtils) mkName getSwarmNames getSwarm;
  mkOneMachine = nixpkgs: modules: index: name:
    attrsets.nameValuePair name {
      inherit nixpkgs;
      modules = (singleton ({
        _module.args = { inherit index name; };
      }) ++ modules);
    };
  mkMachine = nixpkgs: modules: name:
    singleton (mkOneMachine nixpkgs modules 0 name);
  mkSwarm = digits: first: lastex: nixpkgs: modules: name:
    map (index: 
      mkOneMachine nixpkgs modules index (mkName digits index name)
    )  (lists.range first (lastex - 1));
  swarmModules = map import [
      ./modules/networking/hostname.nix
      ./modules/virtualisation/libvirtd.nix
      ./modules/virtualisation/libvirtd-opts.nix
    ];
  nixosModules = nixpkgs: import (nixpkgs + "/nixos/modules/module-list.nix");

  evalMachine = { nodes, commonModules, check }: { nixpkgs, modules }:
    let baseModules = nixosModules nixpkgs;
    in nixpkgs.lib.evalModules {
      modules = (singleton {
        nixpkgs.system = mkDefault "x86_64-linux"; 
        _module = {
          args = {
            inherit nodes baseModules;
            utils = import ./base-utils.nix { 
              inherit nodes;
              inherit (nixpkgs) lib;
            };
          };
          inherit check;
        };
      }) ++ baseModules ++ swarmModules ++ commonModules ++ modules;
      specialArgs = {
        modulesPath = nixpkgs + "/nixos/modules";
      };
    };
  mkSpec = spec@{ meta ? { name = "spec"; description = "my first specification"; }, common ? [], ... }: 
    let 
      userMachines = removeAttrs spec [ "meta" "common" ];
      moduleSet = listToAttrs (concatLists (attrsets.mapAttrsToList (name: value: value name) userMachines));
      nixosConfigurations = rec {
        uncheckedNodes = attrsets.mapAttrs (name: value: evalMachine {
          commonModules = common;
          nodes = uncheckedNodes;
          check = false;
        } value) moduleSet;

        nodes = attrsets.mapAttrs (name: value: evalMachine {
          commonModules = common;
          nodes = uncheckedNodes;
          check = true;
        } value) moduleSet;
      }.nodes;

      parametrizedOutputs = system:
        let
          pkgs = my-nixpkgs.legacyPackages.${system};
          toplevel = name: node: node.config.system.build.toplevel;
          eachToplevel = builtins.mapAttrs toplevel nixosConfigurations;
        in {
          packages = eachToplevel;
        };
    in 
    { inherit nixosConfigurations; }
    // flake-utils.lib.eachDefaultSystem parametrizedOutputs;

  utils = {
    inherit
      mkMachine
      mkSwarm
      getSwarm
      mkSpec;
  };
in

{
  inherit utils;
}