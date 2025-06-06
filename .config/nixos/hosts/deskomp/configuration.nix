{ config, lib, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";

    networking.hostName = "deskomp";
    networking.networkmanager.enable = true; 

    time.timeZone = "America/Detroit";

    nix.settings.experimental-features = ["nix-command" "flakes"]; # enable flakes

    users.users.maxficco = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        shell = pkgs.zsh;
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
        syncthing
        openjdk
        qutebrowser
        tlp
        vlc
#        ngrok
    ];

    services.tlp.enable = true;
    services.tlp.settings = {
        START_CHARGE_THRESH_BAT0 = 30; # 30 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };

    networking.firewall.allowedTCPPorts = [ 25565 22000 ];

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
        (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) 
    ];

    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    system.stateVersion = "24.11"; # DO NOT CHANGE THIS!
}
