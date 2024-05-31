# nixos-configuration

My NixOS configuration file. Trying out flakes. 

# Rebuild using this configuration

Choose a name for your generation

```
export GEN_NAME='{CHOOSE A GENERATION NAME}'
```

If you want to ignore the flake and rebuild monolithically: 

```
sudo nixos-rebuild switch -I nixos-config=./configuration.nix -p $GEN_NAME
```

Rebuild using the new flake (Recommended)

```
sudo nixos-rebuild --flake .#nixos switch --upgrade -p $GEN_NAME
```