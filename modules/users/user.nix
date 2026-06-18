{ vars, ... }:

{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = [ "wheel" "networkmanager" "docker" "vboxusers"];
    
    linger = true;
  };

  security.sudo.wheelNeedsPassword = false;
}
