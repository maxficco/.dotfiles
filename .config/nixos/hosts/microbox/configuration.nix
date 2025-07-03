{ config, lib, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ]; # make sure this file actually exists!

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "template";
    networking.networkmanager.enable = true; 

    time.timeZone = "America/Detroit";

    nix.settings.experimental-features = ["nix-command" "flakes"]; # enable flakes

    users.users.maxficco = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        shell = pkgs.zsh;
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
        nerd-fonts.sauce-code-pro
    ];

    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    system.stateVersion = "25.05"; # DO NOT CHANGE!
}
