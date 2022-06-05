{ config, index, name, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts.default = {
      default = true;
      locations."/".return = "200 \"This is web server ${toString index}, named ${name}\"";
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  swarm.virtualisation.guestConfig = {
    memory = "128MiB";
    storage.vda = {
      volume = "store-${name}";
      size = "128MiB";
    };
    spice = true;
    extraDevices = [ ];
  };
}