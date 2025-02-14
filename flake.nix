{
  description = "My personal NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    nur.url = "github:nix-community/NUR";
    ags.url = "github:Aylur/ags";
  };

  outputs = { nixpkgs, nixpkgs-stable, stylix, nur, home-manager, ... }@inputs:
    let
      system = "aarch64-linux";
      host = "desktop";
      username = "salgadev";
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
      	    inherit system;
            inherit inputs;
            inherit username;
            inherit host;
          };
          modules = [
            ./configuration.nix
            nur.modules.nixos.default
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./hosts/${host}/home.nix;
            }
          ];
        };
      };
    };
}
