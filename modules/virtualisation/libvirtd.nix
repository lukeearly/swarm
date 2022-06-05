{ config, lib, utils, ... }:

with lib;
let
  getNum = value: concatStrings (filter (c: isList (match "[0-9]" c)) (stringToCharacters value));
  getUnit = value: concatStrings (filter (c: !isList (match "[0-9]" c)) (stringToCharacters value));
in
{
  config = mkIf config.swarm.virtualisation.libvirtd.enable {
    boot.kernelModules = [ "kvm-intel" ];
    virtualisation.libvirtd.enable = true;

    # https://nixos.wiki/wiki/NixOps/Virtualization
    systemd.services = lib.mapAttrs' (name: node: lib.nameValuePair "libvirtd-guest-${name}" {
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanges = false; # allows custom rollout via systemd
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
      script = 
        let
          guest = node.config.swarm.virtualisation.guestConfig;
          xml = pkgs.writeText "libvirtd-guest-${name}.xml"
            ''
              <domain type="kvm">
                <name>${name}</name>
                <uuid>UUID</uuid>
                <os>
                  <type>hvm</type>
                </os>
                <memory unit="${getUnit guest.memory}">${getNum guest.memory}</memory>
                <devices>
            ''
            + builtins.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''
                  <disk type="volume">
                    <source volume="${value.volume}"/>
                    <target dev="${name}" bus="virtio"/>
                  </disk>
            '') guest.storage)
            + builtins.optionalString guest.spice ''
                  <graphics type="spice" autoport="yes"/>
                  <input type="keyboard" bus="usb"/>
            ''
            # + builtins.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''
            #       <interface>
            #         <source dev="${hostNic}" mode="bridge"/>
            # ''
            # + builtins.optionalString (builtins.isString value.mac) ''
            #         <mac address="${value.mac}"/>
            # ''
            # + ''
            #         <model type="virtio"/>
            #       </interface>
            # '') guest.interfaces)
            + builtins.concatStringsSep "\n" guest.extraDevices
            + ''
                </devices>
                <features>
                  <acpi/>
                </features>
              </domain>
            '';
        in
          ''
            uuid="$(${pkgs.libvirt}/bin/virsh domuuid '${name}' || true)"
            ${pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
            ${pkgs.libvirt}/bin/virsh start '${name}'
          '';
      preStop =
        ''
          ${pkgs.libvirt}/bin/virsh shutdown '${name}'
          let "timeout = $(date +%s) + 10"
          while [ "$(${pkgs.libvirt}/bin/virsh list --name | grep --count '^${name}$')" -gt 0 ]; do
            if [ "$(date +%s)" -ge "$timeout" ]; then
              # Meh, we warned it...
              ${pkgs.libvirt}/bin/virsh destroy '${name}'
            else
              # The machine is still running, let's give it some time to shut down
              sleep 0.5
            fi
          done
        '';
    }) config.swarm.virtualisation.libvirtd.guests;
  };

  options = {
    swarm.virtualisation.libvirtd = {
      enable = lib.mkEnableOption "libvirtd host support";
      guests = lib.mkOption {
        type = types.attrsOf (types.any);
        description = "libvirtd guests";
      };
    };
  };
}