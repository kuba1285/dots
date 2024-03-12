function command_not_found_handler(){
	echo -e "\e[31m	▄▄▌ ▐ ▄▌ ▄▄▄· .▄▄ · ▄▄▄▄▄▄▄▄ .·▄▄▄▄  \n" \
			"	██· █▌▐█▐█ ▀█ ▐█ ▀. •██  ▀▄.▀·██▪ ██ \n" \
			"	██▪▐█▐▐▌▄█▀▀█ ▄▀▀▀█▄ ▐█.▪▐▀▀▪▄▐█· ▐█▌\n" \
			"	▐█▌██▐█▌▐█ ▪▐▌▐█▄▪▐█ ▐█▌·▐█▄▄▌██. ██ \n" \
			"	 ▀▀▀▀ ▀▪ ▀  ▀  ▀▀▀▀  ▀▀▀  ▀▀▀ ▀▀▀▀▀• \n"
	return 127
}

source ~/.bashrc
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
