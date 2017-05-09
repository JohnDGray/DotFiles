stty -ixon
#PS1="\033[1;32m<\W>$ \033[0;37m"
PS1="\[\033[1;32m\]<\W>$ \[\033[0;37m\]"
export PS1

export PATH=~/bin:"$PATH"

export VISUAL=vim
export EDITOR="$VISUAL"

#set -o vi

alias pd="pushd +1" 
alias begpr="cd $HOME/Documents/BowTieCode; \
             pushd $HOME/Documents/BowTieData; \
             pushd $HOME;"

export SCALA_HOME="/usr/local/share/scala"
export PATH="$SCALA_HOME/bin:$HOME/bin:$PATH"

alias openPasswords='keepass2 ~/Documents/MyPasswordsSecondVersion/MyPasswords.kdbx'
alias python=python3

export BTC="${HOME}/Documents/BowTieCode"
export BTD="${HOME}/Documents/BowTieData"

export PATH="/usr/vin/dot:$PATH"

#alias tmux='tmux -2'

if [ "$TERM" == "xterm" ]; then
    #No it isn't, it's gnome-terminal
    export TERM=xterm-256color
fi

source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
