{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    firefox
    google-chrome
    inputs.zen-browser.packages.${system}.twilight

    onlyoffice-desktopeditors
    thunderbird
    zotero
    joplin-desktop
    typora
    keepassxc

    webtorrent_desktop
    qbittorrent
    yt-dlp
    localsend

    virtualbox
    flatpak
    ocs-url

    bluez
    blueman
  ];
}
