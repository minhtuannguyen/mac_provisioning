#!/bin/bash

set -e
set -x

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

brew_install() {
   brew list "$1" || brew install "$1"
}

brew_install_version() {
   brew list "$1" || brew install "$1@$2" && brew pin "$1@$2"
}
brew_cask() {
   brew list --cask "$1" || brew install --cask "$1"
}

install_terraform() {
    if [[ ! -x /usr/local/bin/terraform ]]; then
        brew install terraform@0.13
        brew pin terraform
        brew pin terraform@0.13
    fi
}

setup_git_config() {
   if [ ! -f "$HOME/.gitconfig" ]; then
      echo "Info   | Setup   | git config"
      git config --global init.defaultBranch master
      git config --global user.email "minhtuannguyen2704@gmail.com"
      git config --global user.name  "Minh Tuan Nguyen"
   fi
}

install_terraform

#git
brew_install git
brew_install tig
setup_git_config

#jvm
brew_install java
brew_install jenv
brew_install clojure
brew_install leiningen

brew_install curl
brew_install wget
brew_install jq
brew_install vim
brew_install pyenv
brew_install tmux
brew_install reattach-to-user-namespace

brew_cask coconutbattery
brew_cask iterm2
brew_cask firefox
brew_cask spotify
brew_cask intellij-idea
brew_cask pycharm-ce
brew_cask lulu
brew_cask keeweb

