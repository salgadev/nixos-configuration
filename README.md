# nixos-configuration

Monolithic NixOS configuration file. No flakes or Home Manager (yet). 

# Rebuild using this configuration

Choose a name for your generation

```
export GEN_NAME='{CHOOSE A GENERATION NAME}'
```

and then rebuild with

```
sudo nixos-rebuild switch -I nixos-config=~/nixos-configuration/configuration.nix -p $GEN_NAME
```