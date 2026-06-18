{ pkgs, vars, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };  

  environment.systemPackages = with pkgs; [
    distrobox
    podman-desktop
    docker-compose            
    kubectl
    kind
    slirp4netns
    fuse-overlayfs
    shadow
  ];
}
