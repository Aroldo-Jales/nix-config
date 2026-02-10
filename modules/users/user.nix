{ vars, ... }:

{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = [ "wheel" "networkmanager" ];
    
    linger = true;
  };

  security.sudo.wheelNeedsPassword = false;
}