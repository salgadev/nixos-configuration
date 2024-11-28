# nixos-configuration

My desktop NixOS configuration. Trying flakes and home manager. 

# System Rebuild 

## Rebuild monolithically (ignoring flake) 
```
sudo nixos-rebuild switch -I nixos-config=./configuration.nix
```

## Rebuild using flake (Recommended)

```
nix flake update 

sudo nixos-rebuild --flake .#desktop switch -p home --impure
```

## Other notes and commands

### Run to debug home manager
```
journalctl -u home-manager-salgadev.service -n 100 --no-pager
```
