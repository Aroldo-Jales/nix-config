let
  username = "myuser";
  hostname = "${username}-laptop";
  homeDirectory = "/home/${username}";
in {
  inherit username hostname homeDirectory;

  fullName = "Your Name";
  email = "you@example.com";

  nixConfigPath = "${homeDirectory}/Documents/nix-config";
  podmanSocket = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
}
