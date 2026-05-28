# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export SHELL=zsh
export EDITOR=nvim
export GTK_THEME=Catppuccin-BL-LB-dark-Macchiato
export __GLX_VENDOR_LIBRARY_NAME=nvidia


autoload -Uz promptinit
promptinit

# Prompt
# Prompt credits go to https://github.com/N3k0Ch4n/dotRice

precmd() { print "" }
PS1='%B%(?.%K{135}.%K{167}) %k %F{183}%4~ / %k%b%f '
PS2='%K{167} %K{235} -> %k '

# oh-my-zsh plugins
plugins=(zsh-autosuggestions git zsh-syntax-highlighting history-substring-search)

source $ZSH/oh-my-zsh.sh
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

alias ls="logo-ls -A"
alias radeontop="radeontop -c -T"
# alias btop="btop --utf-force"
alias vpnconnect="sh $HOME/scripts/vpn.sh"
alias vim=nvim
alias pag="ps aux | grep"
alias sc="xclip -selection clipboard"
export STEAMGAMES="$HOME/.local/share/Steam/steamapps/common"
alias fn="find . -type f | fzf --preview 'cat {}' --ignore-case | grep -v '^$' | xargs -r nvim"

alias mcd="mkdir -p \"\$1\" && cd \"\$1\""
alias f="find . -type f | fzf --preview 'cat {}' --ignore-case | grep -v '^$' | xargs -r"
alias fp="ps aux | fzf | awk '{print $2}' | xargs kill"
export PATH="$HOME/.local/bin:$PATH"
export QT_QPA_PLATFORM=xcb
export XDG_SESSION_TYPE=x11
export WAYLAND_DISPLAY=

if [ -f "$HOME/.c/keys" ]; then
    source "$HOME/.c/keys"
fi
