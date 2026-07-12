{ repoRoot, ... }:

{
  imports = [
    (/. + "${repoRoot}/home/modules/core.nix")
    ./modules/github-ssh.nix
    (/. + "${repoRoot}/home/modules/programs/shells.nix")
    (/. + "${repoRoot}/home/modules/programs/starship.nix")
    (/. + "${repoRoot}/home/modules/services/ssh-agent.nix")
    (/. + "${repoRoot}/home/modules/services/openspec.nix")
    (/. + "${repoRoot}/home/modules/services/rclone-keepass.nix")
  ];
}
