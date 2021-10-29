#!/bin/zsh
set -e
set -x

SCRIPT_DIR="$(
  cd $(dirname "$0")
  pwd -P
)"
carrier_pigeon="minhtuannguyen2704@gmail.com"

find_str_in_zshrc() {
  grep "$1" <.zshrc
}

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
    git config --global init.defaultBranch main
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

install_swamp() {
  if [[ ! -x /usr/local/bin/swamp ]]; then
    curl -L "https://github.com/otto-de/swamp/releases/download/v0.11.0-otto/swamp-darwin-amd64" > /usr/local/bin/swamp
    chmod +x /usr/local/bin/swamp
  fi
}

###

install_python() {
  brew_install python
  brew_install pyenv
}

install_gui_tools() {
  #brew_cask docker
  brew_cask coconutbattery
  brew_cask iterm2
  brew_cask firefox
  brew_cask spotify
  brew_cask intellij-idea
  brew_cask intellij-idea-ce
  brew_cask pycharm-ce
  brew_cask lulu
  brew_cask keeweb
}

install_leiningen_profile() {
  if [ ! -d "$HOME/.lein" ]; then
    mkdir "$HOME/.lein"
    cp "$SCRIPT_DIR/../resources/leiningen/profiles.clj" "$HOME/.lein"
  fi
}

set_jdk_path() {
  if [[ ! "$(find_str_in_zshrc openjdk@11/bin)" ]]; then
    echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >>"$HOME/.zshrc"
    jenv add /usr/local/opt/openjdk@11/
  fi
}

install_jvm() {
  #java
  brew_install openjdk@11
  brew_install jenv
  set_jdk_path

  #clojure
  brew_install clojure
  brew_install leiningen
  install_leiningen_profile
}

install_vim_config() {
  if [ ! -f "$HOME/.vimrc" ]; then
    cp "$SCRIPT_DIR/../resources/vim/.vimrc" "$HOME/.vimrc"
  fi
}

install_others() {
  brew_install curl
  brew_install wget
  brew_install jq
  brew_install node
  brew_install htop
  brew_install the_silver_searcher
  brew_install postgresql

  brew_install vim
  install_vim_config
}

install_aws_tools() {
  install_terraform
  brew_install awscli
  install_swamp
}

install_yubikey_tools() {
  brew_install ykman

  if [[ ! -x /usr/local/bin/lmfa ]]; then
    cp "$SCRIPT_DIR/../resources/yubikey/lmfa" /usr/local/bin/lmfa
  fi
}

install_git() {
  brew_install git
  brew_install tig
  brew_install openssh
  setup_git_config
  setup_ssh_config
}

install_fzf() {
  if [[ ! "$(find_str_in_zshrc fzf.zsh)" ]]; then
    brew_install fzf
    $(brew --prefix)/opt/fzf/install
  fi
}

install_zsh_config() {
  if [ ! -f "$HOME/.zshrc" ]; then
    cp "$SCRIPT_DIR/../resources/zsh/.zshrc" "$HOME/.zshrc"
  fi

  if [ ! -d "$HOME/.config/zsh/custom_config/" ]; then
    mkdir -p "$HOME/.config/zsh/custom_config/"
  fi
}

install_zsh_tools() {
  install_ohmyzsh
  install_zsh_config
  install_antigen
  install_zsh_plugin zsh-users zsh-completions
  install_zsh_plugin zsh-users zsh-autosuggestions
  install_zsh_plugin zsh-users zsh-syntax-highlighting
  install_zsh_plugin chrissicool zsh-256color
  install_zsh_plugin joel-porquet zsh-dircolors-solarized
  install_zsh_plugin agkozak zsh-z

  install_fzf
}

install_tmux_plugins_manager() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

install_tmux_config() {
  if [ ! -f "$HOME/.tmux.conf" ]; then
    cp "$SCRIPT_DIR/../resources/tmux/.tmux.conf" "$HOME/.tmux.conf"
  fi
}

install_tmux_tools() {
  brew_install tmux
  install_tmux_config
  brew_install reattach-to-user-namespace
  brew_install urlview
  brew_install extract_url
  install_tmux_plugins_manager
}

############################ START ####################################

# Download and install Command Line Tools
if [[ ! -x /usr/bin/gcc ]]; then
  xcode-select --install
fi

# Download and install Homebrew
if [[ ! -x /usr/local/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

install_others
install_python
install_git
install_zsh_tools
install_tmux_tools

install_yubikey_tools
install_aws_tools
install_jvm

install_gui_tools
