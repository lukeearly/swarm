{ config, pkgs, lib, ... }:

with lib;
with types;

let
  storageOpts = {
    volume = mkOption {
      type = str;
      example = "store-lb";
      description = "Name of volume";
    };

    pool = mkOption {
      type = str;
      example = "state";
      description = "Name of pool";
    };

    size = mkOption {
      type = str;
      example = "64GiB";
      description = "Storage capacity";
    };

    command = mkOption {
      type = inferred;
      default = name: value: "";
      description = "Command to generate storage device";
    };
  };
  interfaceOpts = {
    type = mkOption {
      type = str;
    };

    mac = mkOption {
      type = nullOr str;
      default = null;
      example = "AA:AA:AA:AA:AA:AA";
      description = "Mac address";
    };

    vlan = mkOption {
      type = int;
      default = 1;
      description = "VLAN";
    };
  };
in
{
  config = {

  };

  options.swarm.virtualisation.guestConfig = {
    memory = mkOption {
      type = str;
      example = "4GiB";
      description = "Memory requirement";
    };
    storage = mkOption {
      type = attrsOf (submodule storageOpts);
      description = "Storage devices";
    };
    # interfaces = mkOption {
    #   type = attrsOf (submodule interfaceOpts);
    #   description = "Network interfaces";
    # };
    spice = mkOption {
      type = bool;
      default = true;
      description = "Enable spice";
    };
    extraDevices = mkOption {
      type = listOf str;
      default = [];
      description = "XML description of extra devices for libvirtd";
    };
  };
}