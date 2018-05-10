#turn off flow control
stty -ixon

#custom prompt
PS1="\[\033[1;32m\]<\W>$ \[\033[0;37m\]"
export PS1

export PATH=~/bin:"$PATH"

export VISUAL=vim
export EDITOR="$VISUAL"
export HISTCONTROL=ignoreboth

{ which gnome-terminal >/dev/null; } && { export TERMINAL=gnome-terminal; }

alias ls="ls --color=auto"
alias pd="pushd +1" 

alias openPasswords='keepass2 ~/Documents/MyPasswordsSecondVersion/MyPasswords.kdbx'
alias fantasy='pushd ~/Documents/FantasyBaseballApplications/Output; vim -O 2070ParadigmShift B P'
alias python=python3

#if [ "$TERM" == "xterm" ]; then
#    export TERM=xterm-256color
#fi

#source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
source "$HOME/.vim/pack/default/start/gruvbox/gruvbox_256palette.sh"
