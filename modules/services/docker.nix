{ pkgs, vars, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  users.users.${vars.username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  networking.firewall.allowedTCPPorts = [ 9443 9000 ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers.portainer = {
      image = "portainer/portainer-ce:latest";
      autoStart = true;

      ports = [
        "9443:9443"
        "9000:9000"
      ];

      volumes = [
        "portainer_data:/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
