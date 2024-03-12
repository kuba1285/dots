function command_not_found_handler(){
	tput setaf 1 && figlet -f smslant 127 not found
	return 127
}

source ~/.bashrc
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
