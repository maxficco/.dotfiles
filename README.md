# Max Ficco's Dotfiles

## Main Packages/Dependencies
- git (version control)
- stow (dotfiles symlinks)
- zsh (shell)
- vim (best text editor)
- sourcecodepro/hack (nerd font)
- brave/qutebrowser (browser)
- python (3)
- openjdk (java)
- gcc (c++)
- rust (use rustup)
- nodejs (coc.nvim needs this)
- bat (for fzf.vim)
- syncthing (notes syncing)

linux specific:
- sway (window manager)
- bemenu (the dmenu of wayland)
- foot (terminal emulator)
- pipewire-pulse (audio)
- pamixer (volume control)
- brightnessctl (brightness control)
- playerctl (media player control)
- vlc (media player)

## Installation
- Install all dependencies and desired packages
- cd ~/.dotfiles
- stow .
- done!
- remember that .gitignore contains "*" so all new dotfiles must be manually added
