{
  description = "My personal NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    nur.url = github:nix-community/NUR;
  };

  outputs = { nixpkgs, stylix, nur, ... }@inputs: {
    nixosConfigurations = {
      # hostname is:
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          nur.nixosModules.nur
          inputs.stylix.nixosModules.stylix
        ];
      };
    };
  };
}
