{
  description = "nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";    
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # networking.hostname = nixos
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./configuration.nix 
          inputs.stylix.nixosModules.stylix
        ];
      };
    };
  };
}
