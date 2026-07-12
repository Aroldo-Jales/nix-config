{ config, pkgs, ... }:

{
  systemd.user.services.openspec-install = {
    Unit = {
      Description = "Install openspec once";
      ConditionPathExists = "!%h/.local/state/openspec-installed";
    };

    Service = {
      Type = "oneshot";
      TimeoutStartSec = "3min";
      Environment = [
        "HOME=${config.home.homeDirectory}"
        "NPM_CONFIG_PREFIX=%h/.npm-global"
        "PATH=${pkgs.nodejs_22}/bin:%h/.npm-global/bin:/run/current-system/sw/bin"
      ];
      ExecStart = toString (pkgs.writeShellScript "install-openspec-once" ''
        set -eu

        mkdir -p "$HOME/.local/state" "$NPM_CONFIG_PREFIX/bin"

        if [ -x "$NPM_CONFIG_PREFIX/bin/openspec" ]; then
          touch "$HOME/.local/state/openspec-installed"
          exit 0
        fi

        ${pkgs.nodejs_22}/bin/npm install -g @fission-ai/openspec@latest
        touch "$HOME/.local/state/openspec-installed"
      '');
    };
  };

  systemd.user.timers.openspec-install = {
    Unit = {
      Description = "Run openspec installer shortly after login";
    };

    Timer = {
      OnStartupSec = "30s";
      Unit = "openspec-install.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
