# Kindle 4 used as an e-ink display over USB (NiLuJe's USBNetwork hack).
# Provides the `kindle-show` command and the network setup it needs.
{ pkgs, ... }:

let
  kindle-show = pkgs.writeShellApplication {
    name = "kindle-show";
    runtimeInputs = with pkgs; [
      cmark # markdown -> HTML
      python3Packages.weasyprint # HTML -> PDF
      poppler-utils # PDF -> PNG (pdftoppm)
      imagemagick # PNG -> screen-ready greyscale PNG (magick)
      openssh # ssh
      gnused # sed
      coreutils # mktemp, cat
    ];
    text = builtins.readFile ./kindle-show.sh;
  };
in
{
  environment.systemPackages = [ kindle-show ];

  # A basic font, so text always has something to render with.
  fonts.packages = [ pkgs.dejavu_fonts ];

  # Give the Kindle's USB network interface a fixed address.
  networking.networkmanager.ensureProfiles.profiles.kindle = {
    connection = {
      id = "kindle";
      type = "ethernet";
      autoconnect = true;
      autoconnect-priority = 10; # beat NetworkManager's automatic "Wired connection"
    };
    match.driver = "cdc_subset;cdc_ether;rndis_host"; # the Kindle has shown up as more than one
    ipv4 = {
      method = "manual";
      address1 = "192.168.15.201/24";
      never-default = true; # never send internet traffic this way
    };
    ipv6.method = "disabled";
  };
}
