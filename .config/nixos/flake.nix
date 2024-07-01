{

    description = "maxficco's flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, ... }:
        let
            lib = nixpkgs.lib;
            system = "x86_64-linux";
        in {
        nixosConfigurations = {
            champloo = lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ 
                    ./configuration.nix
                ];
            };
        };
    };

}
