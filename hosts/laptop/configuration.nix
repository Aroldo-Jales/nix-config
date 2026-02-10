{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/boot/systemd-boot.nix
    ../../modules/system/nix.nix
    ../../modules/system/locale.nix
    ../../modules/system/fonts.nix
    ../../modules/networking/networkmanager.nix
    ../../modules/desktop/plasma.nix
    ../../modules/services/audio.nix
    ../../modules/services/podman.nix
    ../../modules/services/ssh.nix
    ../../modules/packages.nix
    ../../modules/users/user.nix
    ../../modules/cloud/rclone-keepass.nix
  ];

  networking.hostName = "aroldo-laptop";
  system.stateVersion = "24.05";
}
