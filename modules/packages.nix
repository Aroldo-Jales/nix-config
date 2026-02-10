{ pkgs, ... }:

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
    flatpak

    # Dev
    vscode
    dbeaver-bin
    bruno
    sublime3
    git
    cargo
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    # Utils
    gcc
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
    openssl        
    pkg-config
    gnumake 
    perl    
  ];
}
