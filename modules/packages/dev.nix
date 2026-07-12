{ pkgs, ... }:
let
  dotnetCombined = with pkgs.dotnetCorePackages; combinePackages [
    sdk_8_0
    sdk_9_0
    sdk_10_0
  ];
in
{
  environment.systemPackages = with pkgs; [
    vscode
    antigravity
    android-studio
    sublime3

    cargo
    python3
    python3Packages.pip
    python3Packages.virtualenv
    nodejs_22
    dotnetCombined
    dotnet-ef
    flutter

    dbeaver-bin
    bruno
  ];
}
