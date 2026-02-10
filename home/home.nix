{ inputs, pkgs, vars, ... }:

{
  imports = [
    ./modules/github-ssh.nix
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser.enable = true;

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = "24.05";

  programs.git = {
    enable = true;
    settings.user = {
      name = vars.fullName;
      email = vars.email;
    };
  };

  home.sessionVariables.DOCKER_HOST = vars.podmanSocket;

  programs.bash = {
    enable = true;
    sessionVariables.DOCKER_HOST = vars.podmanSocket;

    shellAliases = {
      c2p = "code2prompt . -c";
      ghkey = "ghkey";
      ghkey-rotate = "ghkey-rotate";

      # Portable: run nix-build-laptop.sh from the current git repository root
      nix-lap-build = ''
        bash -lc 'repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"; \
        if [ -z "$repo" ]; then echo "Not inside a git repository."; exit 1; fi; \
        exec "$repo/nix-build-laptop.sh"'
      '';
    };
  };

  programs.bash.initExtra = ''
    export PATH="$HOME/.cargo/bin:$PATH"
  '';

  programs.starship.enable = true;
  programs.vscode.enable = true;

  home.packages = with pkgs; [ starship ];
}