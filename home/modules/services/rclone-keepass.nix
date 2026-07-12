{ pkgs, ... }:

{
  home.packages = with pkgs; [ rclone ];

  systemd.user.services.keepass-sync = {
    Unit = {
      Description = "KeePassXC Sync";
    };

    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone sync \
          "gdrive:seguranca/senhas.kdbx" \
          %h/.keepass/senhas.kdbx
      '';
    };
  };

  systemd.user.timers.keepass-sync = {
    Unit = {
      Description = "Periodic KeePassXC Sync";
    };

    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
      Unit = "keepass-sync.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
