{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    gcc
    gnumake
    pkg-config
    openssl
    perl
    libsecret

    curl
    wget
    ripgrep
    fd
    fzf
    unzip
    p7zip
    htop

    tailscale
    texliveFull
    qalculate-qt
    usbutils
    pciutils
  ];
}
