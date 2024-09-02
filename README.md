# nixos-configuration

My NixOS configuration file. Trying out flakes. 

# Rebuild using this configuration

If you want to ignore the flake and rebuild monolithically: 

```
sudo nixos-rebuild switch -I nixos-config=./configuration.nix
```

Rebuild using the new flake (Recommended)

```
nix flake update && sudo nixos-rebuild --flake .#desktop switch --impure -p unstable
```