{ config, pkgs, lib, ... }:

with lib;
with types;

let
  storageOpts.options = {
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
      type = anything;
      default = name: value: "";
      description = "Command to generate storage device";
    };
  };
  interfaceOpts.options = {
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

  guestConfigOpts.options = {
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

  # guestNode = {
  #   config.swarm.virtualisation.guestConfig = guestConfigOpts;
  # };
in
{
  config = {

  };

  options.swarm.virtualisation = {
    # guestConfig = mkOption {
    #   type = submodule guestConfigOpts;
    #   description = "Guest configuration";
    # };
    guestConfig = mkOption {
      type = submodule guestConfigOpts;
    };

    libvirtd = {
      enable = mkEnableOption "libvirtd host support";
      guests = mkOption {
        # type = attrsOf (submodule guestNode);
        type = attrsOf (submodule guestConfigOpts);
        description = "libvirtd guests";
      };
      pools = mkOption {
        type = attrsOf str;
        description = "libvirtd storage xml definitions";
        default = {};
      };
      nets = mkOption {
        type = attrsOf str;
        description = "libvirtd network xml definitions";
        default = {};
      };
    };
  };
}