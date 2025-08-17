{ config, lib, pkgs, ... }:

let
    secrets = import ./secrets.nix;
in {
    imports = [ ./hardware-configuration.nix ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "bebop-server";
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
        vim # Nano editor is installed by default
        git
        stow
        bemenu # minimal, like dmenu but for wayland
        cbonsai # pretty trees in your terminal
        foot # goated terminal emulator
        python3
        nodejs_22 # for coc.nvim
        brave # browser
        pamixer
        brightnessctl
        playerctl
        bat # for fzf in vim
        neofetch
        cowsay
        ani-cli
        gcc
        yazi
        mpv
        openjdk
        qutebrowser
        tlp
        vlc
    ];

    services.syncthing = {
        enable = true;
        openDefaultPorts = true; # Open ports in the firewall for Syncthing
    }; 

    services.tlp.enable = true;
    services.tlp.settings = {
        START_CHARGE_THRESH_BAT0 = 30; # 30 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };

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

    networking.firewall.allowedTCPPorts = [ 25565 22000 4220 ];
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
                name = "bebop-ssh";
                type = "tcp";
                localIP = "127.0.0.1";
                localPort = 22;
                remotePort = 4220;
            }
            {
                name = "bebop-minecraft";
                type = "tcp";
                localIP = "127.0.0.1";
                localPort = 25565;
                remotePort = 25565;
            }
            {   name = "bebop-syncthing";
                type = "tcp";
                localIP = "127.0.0.1";
                localPort = 22000;
                remotePort = 22000;
            }
            {   name = "bebop-syncthing_udp";
                type = "udp";
                localIP = "127.0.0.1";
                localPort = 22000;
                remotePort = 22000;
            }
            ];
        };
    };

    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    
    programs.zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
    };

    programs.sway = {
        enable=true;
        wrapperFeatures.gtk = true; # so that gtk works properly
    };

    fonts.packages = with pkgs; [
        nerd-fonts.sauce-code-pro
    ];

    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    system.stateVersion = "24.05"; # DO NOT CHANGE THIS!
}
