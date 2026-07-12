{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    haruna
    obs-studio
    weasis
    dcmtk
  ];
}