#turn off flow control
stty -ixon

set -o vi

#custom prompt
PS1="\[\033[1;32m\]<\W>$ \[\033[0;37m\]"
export PS1

export PATH=~/bin:"$PATH"
export PATH="/usr/vin/dot:$PATH"

export VISUAL=vim
export EDITOR="$VISUAL"

alias ls="ls --color=auto"
alias pd="pushd +1" 
alias openPasswords='keepass2 ~/Documents/MyPasswordsSecondVersion/MyPasswords.kdbx'
alias getWeather='curl wttr.in/Cleveland' 
alias python=python3

if [ "$TERM" == "xterm" ]; then
    export TERM=xterm-256color
fi

source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
