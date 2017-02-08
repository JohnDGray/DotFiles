stty -ixon
PS1="\033[1;32m<\W>$ \033[0;37m"
export PS1
export PATH=~/bin:"$PATH"

set -o vi

alias BotRunner='xfreerdp -u BotRunner -p "#AffinityWins" -d BOT-MONSTER -f 192.168.0.59'
alias Development='xfreerdp -u Development -p "#SEvoWins" -d BOT-MONSTER -f 192.168.0.59'
alias CredioScraper='xfreerdp -u CredioScraper -p "#AffinityWins" -d BOT-MONSTER -f 192.168.0.59'
export SCALA_HOME="/usr/local/share/scala"
export PATH="$SCALA_HOME/bin:$HOME/bin:$PATH"
alias openPasswords='keepass2 ~/Documents/MyPasswordsSecondVersion/MyPasswords.kdbx'
#alias tmux='tmux -2'
#alias tmuxi='cd Documents;tmux -2'
#alias hsplit='tmux splitw -h'

if [ "$TERM" == "xterm" ]; then
    #No it isn't, it's gnome-terminal
    export TERM=xterm-256color
fi
