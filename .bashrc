#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

#export XFCE_WALLPAPER=$(grep -m 1 "last-image" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml | awk -F'"' '{print $6}' | xargs -L 1)
alias neofetch='neowofetch --gap -30 --ascii "$(fortune -s | pokemonsay -w 30)"'
alias clear='paclear -s 5 -c yellow'
cheatsh() { curl "http://cheat.sh/$1"; }
eval "$(starship init $(ps -p $$ -o ucomm=))"
