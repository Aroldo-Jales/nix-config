{ pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [

    # Desktop
    firefox
    keepassxc
    thunderbird
    libreoffice
    zotero
    obs-studio
    joplin-desktop
    flatpak
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight

    # Dev
    vscode
    dbeaver-bin
    bruno
    sublime3
    git
    cargo
    python3
    dotnet-sdk_9
    python3Packages.pip
    python3Packages.virtualenv
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

    usbutils   # lsusb
    pciutils   # lspci
    bluez      # bluetoothctl
    blueman    # ui optional
  ];
}
