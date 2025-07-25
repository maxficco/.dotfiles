{

    description = "maxficco's flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
            wahoo = lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ 
                    ./hosts/wahoo/configuration.nix
                ];
            };
        };
    };

}
