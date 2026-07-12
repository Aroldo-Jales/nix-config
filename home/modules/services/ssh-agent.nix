{
  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "SSH agent";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";

      Environment = [
        "SSH_AUTH_SOCK=%t/ssh-agent.socket"
      ];

      ExecStart = "ssh-agent -D -a %t/ssh-agent.socket";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
