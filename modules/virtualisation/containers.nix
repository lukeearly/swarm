{ config, pkgs, ... }:

with lib;

let
  containerOpts = { name, config, ... } : {
    config = mkOption {
      
    };

    privileged = mkOption {
      type = types.bool;
      default = false;
      description = "Privileged container";
    };
  };

in {
  config = {

  };

  options = {
    swarm.containers = mkOption {
      type = with types; attrsOf (submodule containerOpts);
      description = "Container options.";
    };
  };
}