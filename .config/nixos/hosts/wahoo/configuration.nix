{ config, lib, pkgs, ... }:

let
    secrets = import ./secrets.nix;
in {
    imports = [ ./hardware-configuration.nix ]; # make sure this file actually exists!

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "wahoo";
    networking.networkmanager.enable = true; 

    time.timeZone = "America/Detroit";

    nix.settings.experimental-features = ["nix-command" "flakes"]; # enable flakes

    users.users.maxficco = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVEkPUqLxIjBHOSt6hlECiE7IXFW1zbnord+nAXnuts maxficco@ssh.maxfic.co"
        ];
    };

    environment.systemPackages = with pkgs; [
        vim
        stow
        git
        bemenu
        foot
        pamixer
        brightnessctl
        playerctl
        vlc
        python3
        gcc
        neofetch
        cowsay
        cbonsai
        syncthing
        openjdk
        wayvnc
    ];
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

    # server stuff
    services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            AllowUsers = [ "maxficco" ];
        };
    };
    services.fail2ban.enable = true;

    networking.firewall.allowedTCPPorts = [ 25565 22000 4910 5900 ]; # 5900 is for vnc, but only set up for local (blocked by ovh server anyways)
                                                                    # Will need to consider privacy and security if I want to connect over distance
    boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr"; # faster!

    services.frp = {
        enable = true;
        role = "client";
        settings = {
            serverAddr = "server.maxfic.co";
            serverPort = 7000;
            auth = {
                method = "token";
                token = secrets.frpToken;
            };
            proxies = [
            {
                name = "wahoo-ssh";
                type = "tcp";
                localIP = "127.0.0.1";
                localPort = 22;
                remotePort = 4910;
            }
            {
                name = "wahoo-minecraft";
                type = "tcp";
                localIP = "127.0.0.1";
                localPort = 25565;
                remotePort = 25565;
            }
            {   name = "wahoo-syncthing";
                type = "tcp";
                localIP = "127.0.0.1";
                localPort = 22000;
                remotePort = 22000;
            }
            {   name = "wahoo-syncthing_udp";
                type = "udp";
                localIP = "127.0.0.1";
                localPort = 22000;
                remotePort = 22000;
            }
            ];
        };
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
    };

    programs.sway = {
        enable=true;
        wrapperFeatures.gtk = true; # so that gtk works properly
#        extraSessionCommands = ''        
#            export XDG_RUNTIME_DIR=/run/user/$(id -u)
#            export WLR_BACKENDS=headless
#            export WLR_LIBINPUT_NO_DEVICES=1
#            export WLR_HEADLESS_OUTPUT=1920x1080
#            export WAYLAND_DISPLAY=wayland-0
#
#            wayvnc 0.0.0.0 5900 &
#        '';
    };

    fonts.packages = with pkgs; [
        nerd-fonts.sauce-code-pro
    ];

    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    system.stateVersion = "25.05"; # DO NOT CHANGE!
}
