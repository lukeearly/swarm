{ config, ... }:

{
    services.nginx.locations.virtualHosts.default.locations."/is-backup".return = "200 \"This is a backup server!\"";
}