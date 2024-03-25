{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    autofirma-nix = {
      url = "github:nilp0inter/autofirma-nix/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  

  outputs = { self, nixpkgs, home-manager, autofirma-nix }: {

    nixosConfigurations.spectre = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          imports = [
            autofirma-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.users.lae.imports = [
                autofirma-nix.homeManagerModules.default
              ];
            }
          ];
        }
        ./configuration.nix
      ];
    };
  };
}