# dotfiles



## Stack

| Tool | Package | Source |
|------|---------|--------|
| WM | [awesome-git](https://awesomewm.org/) | AUR |
| Compositor | [picom-pijulius-next-git](https://github.com/pijulius/picom) | AUR |
| Bar | [polybar](https://polybar.github.io/) | official |
| Launcher | [rofi](https://davatorium.github.io/rofi/) | official |
| Terminal | [kitty](https://sw.kovidgoyal.net/kitty/) | official |
| Editor | [neovim](https://neovim.io/) | official |
| Shell | zsh + oh-my-zsh | official / AUR |
| Notifications | conky | official |
| Display server | Xorg 21.1 | official |


## Install

### 1. Dependencies

```bash
# Official repos
sudo pacman -S conky kitty neovim polybar rofi zsh stow xorg-xinit xorg-server

# AUR (requires yay)
yay -S awesome-git picom-pijulius-next-git oh-my-zsh-git
```

### 2. Clone

```bash
git clone https://github.com/redeancola/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Stow

```bash
stow awesome conky kitty nvim picom polybar rofi xorg zsh
```

This symlinks each config into the appropriate `~/.config/` or `~/` location.

To unstow:

```bash
stow -D awesome conky kitty nvim picom polybar rofi xorg zsh
```
