# ohmyzsh
alias reload="source ~/.zshrc" #"omz reload"
alias ezsh="code ~/.zshrc"
alias ealias="code ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Dotfiles/ohmyzsh/aliases.zsh"
alias econfig="code ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Dotfiles/ohmyzsh/config.zsh"
# ls
alias l="eza -lF --icons --no-quotes --no-permissions --git --group-directories-first"
alias la="l -a"
alias lz="l --total-size"
alias laz="la --total-size"
alias lt="l --tree --ignore-glob=node_modules --git-ignore"
alias lat="la --tree --ignore-glob=node_modules --git-ignore"
alias ltz="l --tree --total-size --ignore-glob=node_modules --git-ignore"
alias lt1="lt --tree --level=2"
alias lat1="lat --tree --level=2"
alias ltz1="ltz --tree --level=2"
alias ltd="lt --only-dirs"
alias latd="lat --only-dirs"
alias ltdz="ltz --only-dirs"
alias ltd1="lt1 --only-dirs"
alias latd1="lat1 --only-dirs"
alias ltdz1="ltz1 --only-dirs"
# cd
alias c="cd"
alias cl='(){ cd -- "$@" && l; }'
alias cla='(){ cd -- "$@" && la; }'
# grep
alias -g grp="| grep"
# asdf
alias asd="asdf"
# vscode
alias codee="code ."
# git
alias push="git push"
alias pull="git pull"
alias commit="git commit -m"
alias add="git add"
alias status="git status"
# editor
alias e="$EDITOR"
alias el="fc"
# Codex
alias cx="codex"
alias cxu="brew upgrade --cask codex"
alias cxl="codex -c model_reasoning_effort=low"
alias cxr="codex resume --last"
# MacOS
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
alias finder="ofd"
# Mole
# https://mole.fit
alias clean="mo"
