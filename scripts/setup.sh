#!/bin/zsh
set -e
set -x

SCRIPT_DIR="$(
  cd $(dirname "$0")
  pwd -P
)"
carrier_pigeon="minhtuannguyen2704@gmail.com"

brew_install() {
  brew list "$1" || brew install "$1"
}

#install a certain version of the software and stick to it
brew_install_version() {
  brew list "$1" || brew install "$1@$2" && brew pin "$1@$2"
}
brew_cask() {
  brew list --cask "$1" || brew install --cask "$1"
}

install_terraform() {
  brew_install warrensbox/tap/tfswitch
  tfswitch 0.13.7
}

install_ohmyzsh() {
  if [ -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh is installed"
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

install_zsh_plugin() {
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$2" ]; then
    git clone "https://github.com/$1/$2" "$HOME/.oh-my-zsh/custom/plugins/$2"
  fi
}

setup_git_config() {
  if [ ! -f "$HOME/.gitconfig" ]; then
    echo "Info   | Setup   | git config"
    git config --global init.defaultBranch master
    git config --global user.email "$carrier_pigeon"
    git config --global user.name "Minh Tuan Nguyen"
  fi
}

setup_ssh_config() {
  if [ ! -d "$HOME/.ssh" ]; then
    mkdir "$HOME/.ssh"
    cp "$SCRIPT_DIR/../resources/ssh/config" "$HOME/.ssh/config"
    cd "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$carrier_pigeon" -f id_rsa_github_private
    ssh-keygen -t ed25519 -C "$carrier_pigeon" -f id_rsa_github_work
    cd -
  fi
}

install_antigen() {
  if [ ! -f "$HOME/.antigen/antigen.zsh" ]; then
    mkdir -p "$HOME/.antigen"
    curl -Ls git.io/antigen >"$HOME/.antigen/antigen.zsh"
  fi
}

download_remote_config() {
  if [ ! -f "$HOME/$1" ]; then
    curl -s "https://raw.githubusercontent.com/minhtuannguyen/$1/master/$1" >"$1"
  fi
}

install_swamp() {
  if [[ ! -x /usr/local/bin/swamp ]]; then
    curl -s "https://github.com/otto-de/swamp/releases/download/v0.11.0-otto/swamp-darwin-amd64" >/usr/local/bin/swamp
    chmod +x /usr/local/bin/swamp
  fi
}

###

install_remote_config() {
  download_remote_config .vimrc
  download_remote_config .tmux.conf
  download_remote_config .zshrc
}

install_python() {
  brew_install python
  brew_install pyenv
}

install_gui_tools() {
  brew_cask coconutbattery
  brew_cask iterm2
  brew_cask firefox
  brew_cask spotify
  brew_cask intellij-idea
  brew_cask pycharm-ce
  brew_cask lulu
  brew_cask keeweb
}

install_jvm() {
  brew_install java
  brew_install jenv
  brew_install clojure
  brew_install leiningen
}

install_others() {
  brew_install curl
  brew_install wget
  brew_install jq
  brew_install vim
  brew_install node
  brew_install htop
  brew_install fzf
}

install_aws_tools() {
  install_terraform
  brew_install awscli
  install_swamp
}

install_git() {
  brew_install git
  brew_install tig
  brew_install openssh
  setup_git_config
  setup_ssh_config
}

install_zsh_tools() {
  install_ohmyzsh
  install_antigen
  install_zsh_plugin zsh-users zsh-completions
  install_zsh_plugin zsh-users zsh-autosuggestions
  install_zsh_plugin zsh-users zsh-syntax-highlighting
  install_zsh_plugin chrissicool zsh-256color
  install_zsh_plugin joel-porquet zsh-dircolors-solarized
}

install_tmux_plugins_manager() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

install_tmux_tools() {
  brew_install tmux
  brew_install reattach-to-user-namespace
  brew_install urlview
  brew_install extract_url
  install_tmux_plugins_manager
}

############################ START ####################################

# Download and install Command Line Tools
if [[ ! -x /usr/bin/gcc ]]; then
  echo "Info   | Install   | xcode"
  xcode-select --install
fi

# Download and install Homebrew
if [[ ! -x /usr/local/bin/brew ]]; then
  echo "Info   | Install   | homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#install_python
#install_others
install_git
#install_aws_tools
#install_jvm
#install_remote_config
#install_gui_tools
#install_zsh_tools
#install_tmux_tools
