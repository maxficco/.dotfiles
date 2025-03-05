{

    description = "maxficco's flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        ngrok.url = "github:ngrok/ngrok-nix";
    };

    outputs = { self, nixpkgs, ngrok, ... } @ inputs:
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
                    ngrok.nixosModules.ngrok
                    ({ pkgs, ... }: {
                      nixpkgs.config.allowUnfree = true;
                      services.ngrok = {
                        enable = true;
                        extraConfig = { };
                        extraConfigFiles = [
                        "/etc/ngrok.yml"
                          # reference to files containing `authtoken` and `api_key` secrets
                          # ngrok will merge these, together with `extraConfig`
                        ];
                        tunnels = {
                            minecraft = {
                                proto = "tcp";
                                addr = 25565;
                            };
                            syncthing = {
                                proto = "tcp";
                                addr = 22000;
                            };
                        };
                      };
                    })
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
