{ config, name, lib, ... }:

{
  networking.hostName = lib.mkDefault name;
}