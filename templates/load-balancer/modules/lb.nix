{ config, lib, nodes, utils, ... }:

{
    services.nginx = {
        enable = true;
        virtualHosts.default = {
            default = true;
            locations."/".proxyPass = "http://backend";
        };
        upstreams.backend.servers = 
            lib.attrsets.mapAttrs' (name: value:
                lib.attrsets.nameValuePair value.config.networking.hostName {
                    backup = false;
                }) (utils.getSwarm 2 0 4 "web")
            // lib.attrsets.mapAttrs' (name: value:
                lib.attrsets.nameValuePair value.config.networking.hostName {
                    backup = true;
                }) (utils.getSwarm 2 0 2 "backup");
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
}