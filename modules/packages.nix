{ repoRoot, ... }:

{
  imports = [
    (/. + "${repoRoot}/modules/packages/base.nix")
    (/. + "${repoRoot}/modules/packages/desktop.nix")
    (/. + "${repoRoot}/modules/packages/dev.nix")
    (/. + "${repoRoot}/modules/packages/media.nix")
    (/. + "${repoRoot}/modules/packages/kde.nix")
  ];
}
