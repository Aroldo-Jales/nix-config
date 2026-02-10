{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ rclone ];

  systemd.user.services.keepass-sync = {
    description = "KeePassXC Sync";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone sync \
          "gdrive:seguranca/senhas.kdbx" \
          %h/.keepass/senhas.kdbx
      '';
    };
  };

  systemd.user.timers.keepass-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
    };
  };
}
