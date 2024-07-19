{ config, lib, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "bebop";
    networking.networkmanager.enable = true; 

    time.timeZone = "America/Denver";

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
    ];
    nixpkgs.config.allowUnfree = true; 
    networking.firewall.allowedTCPPorts = [ 25565 ];

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

    system.stateVersion = "24.05"; # DO NOT CHANGE THIS!
}
