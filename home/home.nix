{ config, pkgs, lib, vars, ... }:

{
  imports = [
    ./modules/github-ssh.nix
  ];

  home.username = "aroldoljs";
  home.homeDirectory = "/home/aroldoljs";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    openssh
    starship
  ];

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "SSH agent";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";

      # Socket fixo
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

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
  };

  home.activation.installOpenspec = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export HOME="${config.home.homeDirectory}"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    mkdir -p "$NPM_CONFIG_PREFIX/bin"
    ${pkgs.nodejs_22}/bin/npm install -g @fission-ai/openspec@latest
  '';

  programs.bash = {
    enable = true;
    
    shellAliases = {
      c2p = "code2prompt . --clipboard";
    };

    initExtra = ''
      eval "$(starship init bash)"
    '';
  };

  /*
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = "$directory$git_branch$git_status$container\n$character";

      container = {
        disabled = false;
        format = "📦 [$name]($style) ";
        style = "bold blue";
      };

      directory = {
        format = "[$path]($style) ";
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        format = "🌿 [$branch]($style) ";
        style = "bold purple";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold yellow";
      };

      character = {
        success_symbol = "[>](bold green) ";
        error_symbol = "[>](bold red) ";
      };
    };
  };*/

  programs.starship = {
  enable = true;

  settings = {
    "$schema" = "https://starship.rs/config-schema.json";

    format = "[░▒▓](#a3aed2)[ ♞ ♜ ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736   bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

    directory = {
      style = "fg:#e3e5e5 bg:#769ff0";
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncation_symbol = "…/";
      substitutions = {
        "Documents" = " 󰈙 ";
        "Downloads" = "  ";
        "Music" = "  ";
        "Pictures" = "  ";
      };
    };

    git_branch = {
      symbol = "";
      style = "bg:#394260";
      format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
    };

    git_status = {
      style = "bg:#394260";
      format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
    };

    nodejs = {
      symbol = "";
      style = "bg:#212736";
      format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
    };

    rust = {
      symbol = "";
      style = "bg:#212736";
      format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
    };

    golang = {
      symbol = "";
      style = "bg:#212736";
      format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
    };

    php = {
      symbol = "";
      style = "bg:#212736";
      format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
    };

    time = {
      disabled = false;
      time_format = "%R";
      style = "bg:#1d2230";
      format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
    };
  };
};

  programs.zsh = {
    enable = true;

    initContent = ''
      eval "$(starship init zsh)"
    '';
  };
}
