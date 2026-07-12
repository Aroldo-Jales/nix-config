{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.signond
    kdePackages.signon-kwallet-extension
    kdePackages.kio-gdrive
    kdePackages.kdepim-addons
  ];
}
