{ vars, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix

    ../../modules/boot/systemd-boot.nix
    ../../modules/system/nix.nix
    ../../modules/system/locale.nix
    ../../modules/system/fonts.nix
    ../../modules/networking/networkmanager.nix
    ../../modules/desktop/plasma.nix
    ../../modules/services/audio.nix
    /*../../modules/services/podman.nix*/
    ../../modules/services/docker.nix
    ../../modules/services/ssh.nix
    ../../modules/packages.nix
    ../../modules/users/user.nix
    ../../modules/cloud/rclone-keepass.nix
  ];

  networking.hostName = "${vars.username}-laptop";
  system.stateVersion = "24.11";
  
  services.tailscale.enable = true;

  virtualisation.virtualbox.host = {
    enable = true;
    enableHardening = true;
    addNetworkInterface = true;
  };

  users.groups.vboxusers = {};

  home-manager.backupFileExtension = "hm-bak";

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    icu
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    PATH = "$HOME/.cargo/bin:$PATH";
  };
}
