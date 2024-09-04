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

## Nightly Home Manager version
Still under heavy development. Can't guarantee stability. 

```
sudo nixos-rebuild --flake .#desktop switch --impure -p home
```

Useful to debug home manager
```
journalctl -u home-manager-salgadev.service -n 100 --no-pager
```
