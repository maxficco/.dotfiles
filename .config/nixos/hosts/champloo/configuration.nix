{ config, lib, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";

    networking.hostName = "champloo";
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
        bemenu # minimal, like dmenu but for wayland
        cbonsai # pretty trees in your terminal
        foot # goated terminal emulator
        python3
        nodejs_22 # for coc.nvim
        pamixer
        brightnessctl
        playerctl
        bat # for fzf in vim
        neofetch
        cowsay
        ani-cli
        stow
        gcc
        linuxKernel.packages.linux_6_6.rtl88xxau-aircrack
        yazi
        mpv
        syncthing
        qutebrowser
    ];
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

    # load driver for Archer AC600 T2U Plus wifi usb antenna, disable native contoller
    boot.extraModulePackages = [ pkgs.linuxKernel.packages.linux_6_6.rtl88xxau-aircrack ];
    boot.blacklistedKernelModules = [ "iwl3945" ];

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
