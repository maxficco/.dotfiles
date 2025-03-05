{ config, lib, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ]; # make sure this file actually exists!

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";

    networking.hostName = "template";
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
        stow
        git
        bemenu # minimal, like dmenu but for wayland
        cbonsai # pretty trees in your terminal
        foot # goated terminal emulator
        nodejs_22 # for coc.nvim
        brave # browser
        pamixer
        brightnessctl
        playerctl
        python3
        bat # for fzf in vim
        neofetch
        cowsay
        gcc
        vlc
    ];
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
