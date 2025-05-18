{

    description = "maxficco's flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, ... } @ inputs:
        let
            lib = nixpkgs.lib;
        in {
        nixosConfigurations = {
            champloo = lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ 
                    ./hosts/champloo/configuration.nix
                ];
            };
            bebop = lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ 
                    ./hosts/bebop/configuration.nix
                ];
            };
            deskomp = lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ 
                    ./hosts/deskomp/configuration.nix
                ];
            };
        };
    };

}
