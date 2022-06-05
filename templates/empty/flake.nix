{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    swarm.url = "gitlab:swarm/swarm";
    swarm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, swarm, ... }: with swarm.utils; mkSpec {
    meta = {
      name = "spec";
      description = "my first specification";
    };

    common = [ ];
  };
}
