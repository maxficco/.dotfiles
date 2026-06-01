I use [Vim](https://www.vim.org) and [Zsh](https://zsh.org).

On my main laptop I use [MacOS](https://www.youtube.com/watch?v=dQw4w9WgXcQ), [Homebrew](https://brew.sh), and [Ghostty](https://ghostty.org).

On everything else I use [NixOS](https://nixos.org), [Sway](https://swaywm.org), and [foot](https://codeberg.org/dnkl/foot).

On a mini server I also use [frp](https://github.com/fatedier/frp) with a cheap VPS from [OVHcloud](https://us.ovhcloud.com/).  It's like having a P.O. box!

---
I use [GNU Stow](https://www.gnu.org/software/stow/) to symlink my dotfiles:
```
cd ~/.dotfiles
stow . --no-folding
```
By using `--no-folding`, if folders (e.g. `~/.local/bin`) don't already exist, GNU stow will create the folder and then symlink each of the files within. Otherwise, the entire folder will be symlinked and any new files the system writes there will actually land inside `~/.dotfiles`, even if we don't want them to.

---
to build a new NixOS system follow [these notes](.config/nixos/README.md)
