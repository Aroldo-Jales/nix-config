{
  description = "NixOS KDE Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    vars = import /etc/nixos/vars.nix;
      

    specialArgs = {
      inherit inputs vars;
    };
  in {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs;

      modules = [
        ./hosts/laptop/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;

          home-manager.users.${vars.username} =
            import ./home/home.nix;
        }
      ];
    };
  };
}
