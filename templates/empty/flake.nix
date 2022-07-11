{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    swarm.url = "github:lukeearly/swarm";
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
