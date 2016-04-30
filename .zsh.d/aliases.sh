## Directory movement
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

## Git aliases
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit -m"
alias gp="git push"
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gl='git log --oneline --graph --decorate --all'
alias gll='git log --all --decorate --graph --pretty=format:"%C(yellow)%h%Creset %C(auto)%d%Creset %Cblue%ar%Creset %Cred%an%Creset %n%w(72,1,2)%s"'

## Programs
alias m="matlab -nodesktop -nosplash"
alias r="ranger"
alias calculator="bc -l"

# This alias should open mplayer in fullscreen (http://crunchbang.org/forums/viewtopic.php?id=20178&p=2)
alias play="mplayer -sws 10 -vf-add yadif=1,scale=1920:-2:1:0:arnd=1"

# Composer (note: I should change this so that it disables xdebug)
alias c="$(which composer)"
alias ci="$(which composer) install"
