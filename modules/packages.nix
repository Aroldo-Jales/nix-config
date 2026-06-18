{ pkgs, inputs, ... }:

let
  dotnetCombined = with pkgs.dotnetCorePackages; combinePackages [
    sdk_8_0
    sdk_9_0
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Desktop
    firefox
    google-chrome
    keepassxc
    thunderbird
    libreoffice
    zotero
    obs-studio
    joplin-desktop
    flatpak
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight
    webtorrent_desktop
    qbittorrent
    vlc
    haruna
    virtualbox
    weasis

    # Dev
    vscode
    antigravity
    android-studio
    dbeaver-bin
    bruno
    sublime3
    git
    cargo
    python3
    nodejs_22
    dotnetCombined
    dotnet-ef
    python3Packages.pip
    python3Packages.virtualenv
    flutter
    libsecret

    # Utils
    gcc
    curl
    wget
    dcmtk
    tailscale
    ripgrep
    fd
    fzf
    unzip
    p7zip
    htop
    starship
    openssh
    openssl
    pkg-config
    gnumake
    perl
    ocs-url
    yt-dlp
    qalculate-qt
    localsend

    usbutils
    pciutils
    bluez
    blueman

    # ui
    libsForQt5.qtstyleplugin-kvantum
  ];
}
