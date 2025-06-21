I use [Vim](https://www.vim.org) (zealot) and [Zsh](https://zsh.org) (agnostic).

On my main laptop I use [MacOS](https://www.youtube.com/watch?v=dQw4w9WgXcQ), [Homebrew](https://brew.sh), and [Ghostty](https://ghostty.org).

On everything else I use [NixOS](https://nixos.org), [Sway](https://swaywm.org), and [foot](https://codeberg.org/dnkl/foot).

On a mini server I also use [frp](https://github.com/fatedier/frp) w/ a cheap VPS from [OVHcloud](https://us.ovhcloud.com/).  It's like having a P.O. box!

---
I use [GNU Stow](https://www.gnu.org/software/stow/) to symlink my dotfiles:
```
cd ~/.dotfiles`
stow .
```
I'm taking a bit of a lazy approach (using stow on all of my dotfiles instead of individual subfolders).  To avoid issues in symlinked folders across different devices, my `.gitignore` contains `*` so all new files must be manually added.

---
to build a new NixOS system follow [these notes](.config/nixos/README.md)
