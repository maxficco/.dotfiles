### General file structure
```
.config/nixos/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── host1/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── host2/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── ...
├── modules/
│   └── common.nix
└── README.md
```
### Creating a new host

after setting up a basic nixos install and cloning .dotfiles:
```
$ cd ~/.dotfiles/.config/nixos
$ mkdir hosts/new-host
$ cp hosts/template/configuration.nix hosts/new-host
$ cp /etc/nixos/hardware-configuration.nix hosts/new-host
$ sudo nixos-rebuild switch --flake .#new-host
```
> don't forget to manually add these files to git if wanting to commit/push changes (symptom of using GNU Stow)

(optional) override default config with flakes config:
```
$ sudo rm -rf /etc/nixos
$ sudo ln -s ~/.dotfiles/.config/nixos /etc/nixos
```
this deletes the default configuration files and creates a symlink to /etc/nixos, the default location that `nixos-rebuild` looks to.  This way, the `--flake` can be omitted in the rebuild command.
