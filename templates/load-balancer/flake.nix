{
    inputs = {
        nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-21.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        swarm.url = "github:lukeearly/swarm";
        swarm.inputs.nixpkgs.follows = "nixpkgs-latest";
    };

    outputs = { nixpkgs-latest, swarm, ... }: with swarm.utils; mkSpec {
        meta = {
            name = "dam";
            description = "dam.";
        };

        common = [
            { boot.isContainer = true; }
        ];

        lb = mkMachine nixpkgs-latest [
            ./modules/lb.nix
        ];

        web = mkSwarm 2 0 4 nixpkgs-latest [
            ./modules/web.nix
        ];

        backup = mkSwarm 2 0 2 nixpkgs-latest [
            ./modules/web.nix
            ./modules/backup.nix
        ];
    };
}
