export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
#plugins=(git)
plugins=(
    zsh-z
	zsh-completions
	zsh-autosuggestions
	brew
	urltools
	git
	git-extras
	zsh-syntax-highlighting
	tig
	osx
	lein
	encode64
	docker
	colored-man-pages
	colorize
	zsh-256color
	zsh-dircolors-solarized
	fzf
)
source $ZSH/oh-my-zsh.sh

#########

export PATH="/usr/local/sbin:$PATH"

setopt RM_STAR_WAIT
COMPLETION_WAITING_DOTS="true"

source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')


#antigen
source "$HOME/.antigen/antigen.zsh"
antigen use oh-my-zsh
antigen theme robbyrussell
if [[ "$OSTYPE" == "darwin"* ]]; then
    antigen bundle osx
fi
antigen apply
autoload -U compinit && compinit

alias pullall=' find . -maxdepth 3 -name .git -type d | rev | cut -c 6- | rev | xargs -I {} sh -c  "echo \"\n\" {} \"\n\"; git -C {} pull"'
alias git='LANG=en_US.UTF-8 git'
alias brew_cleanup='brew prune; brew cleanup -s; brew doctor; brew cleanup; brew missing'
alias ssh_backup='rsync --numeric-ids -avze ssh "$BACKUP_PATH_LOCAL" "$BACKUP_PATH_REMOTE"'

#load custom config
for conf in "$HOME/.config/zsh/custom_config/"*.zsh; do
  source "${conf}"
done
unset conf
