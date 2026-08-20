### General file structure
```
.config/nixos/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── <hostname1>/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── <hostname2>/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── template/
│   │   └── configuration.nix
│   └── ...
└── README.md
```
### Creating a new host

after setting up a basic nixos install and cloning (+stowing) the dotfiles:
```
$ cd ~/.dotfiles/.config/nixos
$ mkdir hosts/new-host
$ cp hosts/template/configuration.nix hosts/new-host
$ cp /etc/nixos/hardware-configuration.nix hosts/new-host
```
Then:
- in `new-host/configuration.nix`, make sure boot options are correct and copy over `system.stateVersion` from `/etc/nixos/configuration.nix`
- edit `flake.nix` to include the new host
- remember that nix only sees tracked files, so config files need at least `git add -N` before they will evaluate.
Finally:
```
$ sudo nixos-rebuild switch --flake .#new-host
```

(optional) override default config with flakes config:
```
$ sudo rm -rf /etc/nixos
$ sudo ln -s ~/.dotfiles/.config/nixos /etc/nixos
```
this deletes the default configuration files and creates a symlink to our config from `/etc/nixos`, the default location that `nixos-rebuild` looks to.  This way, `--flake` can be omitted in the rebuild command.

### Updating NixOS

to pull in the latest packages within the current release:
```
$ cd ~/.dotfiles/.config/nixos
$ nix flake update
$ sudo nixos-rebuild switch --flake .#hostname
```
> `nix flake update` re-resolves every input in `flake.nix` and rewrites `flake.lock`.
> you can pass an input name (e.g. `nix flake update nixpkgs`) to update only that input
> use `--commit-lock-file` to automatically commit the result.
>
> note that when rebuilding the current host, `#hostname` can be omitted.


to move to a new NixOS release, edit the ref in `flake.nix` first, e.g.:
```
nixpkgs.url = "github:NixOS/nixpkgs/nixos-XX.XX";
```
> then rebuild as above. 
>
> remember, leave `system.stateVersion` alone!

### useful `nixos-rebuild` variants:

| command | effect |
| --- | --- |
| `nixos-rebuild boot` | apply at next boot only -- safer for kernel/driver bumps |
| `nixos-rebuild test` | activate now, no bootloader entry (reboot undoes it) |
| `nixos-rebuild build` | just build `./result`, no root needed |
| `nixos-rebuild switch --rollback` | return to the previous generation |


a useful sequence to inspect what an update actually changes before committing to it:
```
$ nixos-rebuild build --flake .        # sudo not needed; leaves ./result
$ nix store diff-closures /run/current-system ./result
$ sudo nixos-rebuild switch --flake .
```
> the *closure* of a store path is that path plus everything it transitively references, so this diffs the whole dependency graph rather than just what was changed in config.
