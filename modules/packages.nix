{ pkgs, inputs, ... }:

let
  dotnetCombined = with pkgs.dotnetCorePackages; combinePackages [
    sdk_8_0
    sdk_9_0
  ];

  system = pkgs.stdenv.hostPlatform.system;
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Browsers
    firefox
    google-chrome
    inputs.zen-browser.packages.${system}.twilight

    # Office / produtividade
    onlyoffice-desktopeditors
    thunderbird
    zotero
    joplin-desktop
    typora
    keepassxc

    # Multimídia
    vlc
    haruna
    obs-studio

    # Downloads / torrents
    webtorrent_desktop
    qbittorrent
    yt-dlp

    # Comunicação / compartilhamento
    localsend
    # rustdesk

    # Virtualização / compatibilidade
    virtualbox
    flatpak
    ocs-url

    # Desenvolvimento - editores / IDEs
    vscode
    antigravity
    android-studio
    sublime3

    # Desenvolvimento - ferramentas gerais
    git
    gcc
    gnumake
    pkg-config
    openssl
    perl
    libsecret

    # Desenvolvimento - linguagens / runtimes
    cargo
    python3
    python3Packages.pip
    python3Packages.virtualenv
    nodejs_22
    dotnetCombined
    dotnet-ef
    flutter

    # Desenvolvimento - APIs / banco de dados
    dbeaver-bin
    bruno

    # Terminal / CLI
    curl
    wget
    ripgrep
    fd
    fzf
    unzip
    p7zip
    htop
    starship
    openssh

    # Rede / VPN
    tailscale

    # Ciência / documentos técnicos
    texliveFull
    qalculate-qt

    # Medicina / DICOM
    weasis
    dcmtk

    # Hardware / dispositivos
    usbutils
    pciutils
    bluez
    blueman

    # Interface / KDE
    libsForQt5.qtstyleplugin-kvantum

    # KDE / contas online
    kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.signond
    kdePackages.signon-kwallet-extension
    kdePackages.kio-gdrive
    kdePackages.kdepim-addons
  ];
}
