function cheatsh() { curl "http://cheat.sh/$1"; }
eval "$(starship init $(ps -p $$ -o ucomm=))"
alias ls="eza --icons --git"
alias la="eza -a --icons --git"
alias ll="eza -aahl --icons --git"
alias lt="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"
alias lta="eza -T -a -I 'node_modules|.git|.cache' --color=always --icons | less -r"
alias vc='code' # gui code editor
alias clear='paclear -s 5 -c yellow'
