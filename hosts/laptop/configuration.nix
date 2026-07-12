{ repoRoot, vars, ... }:
let
  localHardwareConfiguration =
    /. + "${repoRoot}/hosts/laptop/hardware-configuration.nix";
  hardwareConfiguration =
    if builtins.pathExists localHardwareConfiguration
    then localHardwareConfiguration
    else /etc/nixos/hardware-configuration.nix;
in
{
  imports = [
    hardwareConfiguration

    ../../modules/boot/systemd-boot.nix
    (/. + "${repoRoot}/modules/system/home-manager.nix")
    ../../modules/system/nix.nix
    (/. + "${repoRoot}/modules/system/nix-ld.nix")
    ../../modules/system/locale.nix
    ../../modules/system/fonts.nix
    ../../modules/networking/networkmanager.nix
    (/. + "${repoRoot}/modules/networking/tailscale.nix")
    ../../modules/desktop/plasma.nix
    ../../modules/services/audio.nix
    /*../../modules/services/podman.nix*/
    ../../modules/services/docker.nix
    ../../modules/services/ssh.nix
    ../../modules/packages.nix
    ../../modules/users/user.nix
  ];

  networking.hostName =
    if vars ? hostname
    then vars.hostname
    else "${vars.username}-laptop";
  system.stateVersion = "24.11";

  virtualisation.virtualbox.host = {
    enable = true;
    enableHardening = true;
    addNetworkInterface = true;
  };

  users.groups.vboxusers = {};

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.enableRedistributableFirmware = true;
}
