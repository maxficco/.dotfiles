# Max Ficco's Dotfiles

## Packages/Dependencies
- stow (dotfiles symlinks)
- zsh (shell)
- vim (best text editor)
- git (version control)
- sway (window manager)
- bemenu (the dmenu of wayland)
- foot (terminal emulator)
- pipewire-pulse (audio)
- pamixer (volume control)
- brightnessctl (brightness control)
- playerctl (media player control)
- cbonsai (pretty trees in your terminal)
- sourcecodepro (nerd font)
- brave (browser)
- nodejs (coc.nvim needs this)
- python (3)
- openjdk (java)
- gcc (c++)
- rust (use rustup)
- bat (for fzf.vim)
- neofetch (i use arch btw)
- cowsay (for fun)
- yay (for aur)
- ani-cli (anime)

## Installation
### Linux:
`sudo pacman -S stow zsh vim git sway bemenu foot pipewire-pulse pamixer brightnessctl playerctl ttf-sourcecodepro-nerd nodejs python gcc jdk-openjdk bat neofetch cowsay`
`sudo pacman -S yay && yay -S brave-bin cbonsai`

### MacOS:
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
`brew install stow zsh vim git cbonsai brave-browser node@20 python gcc rustup-init bat neofetch cowsay font-sauce-code-pro-nerd-font`
