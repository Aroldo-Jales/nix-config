{ pkgs, vars, ... }:

{
  home.username = vars.username;
  home.homeDirectory = vars.homeDirectory or "/home/${vars.username}";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    openssh
    starship
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
  };
}
