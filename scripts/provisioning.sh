#!/bin/bash
set -e
set -x

CPU=$(uname -p)

SCRIPT_DIR="$(
  cd "$(dirname "$0")"
  pwd -P
)"

carrier_pigeon=${1:-foo.bar@gmail.com}
user_name=${2:-Mueller}

find_str_in_zshrc() {
  grep "$1" <"$HOME/.zshrc"
}

append_line_to_file() {
  printf "\n%s\n" "$1" >>"$2"
}

append_zshrc() {
  append_line_to_file "$1" "$HOME/.zshrc"
}

brew_install() {
  brew list "$1" || brew install "$1"
}

brew_cask_install() {
  brew list --cask "$1" || brew install --cask "$1"
}

install_terraform() {
  brew_install warrensbox/tap/tfswitch
  tfswitch 0.13.7
}

install_ohmyzsh() {
  if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

read_resource_content() {
  cat "$SCRIPT_DIR/../resources/$1"
}

setup_ohmyzsh_config() {
  #set plugins
  plugins_list=$(read_resource_content zsh/.plugins_zshrc)
  sed -i '' -e "s/plugins=(git)/$plugins_list/" "$HOME/.zshrc"

  #add custom config
  if [[ ! "$(find_str_in_zshrc ___CUSTOM ZSH___)" ]]; then
    read_resource_content zsh/.custom_zshrc >>"$HOME/.zshrc"
    append_zshrc 'export PATH="/usr/local/sbin:$PATH"'
    append_zshrc 'setopt RM_STAR_WAIT'
    append_zshrc 'COMPLETION_WAITING_DOTS="true"'
    append_zshrc 'autoload -U compinit && compinit'
  fi
}

install_zsh_plugin() {
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$2" ]; then
    git clone "https://github.com/$1/$2" "$HOME/.oh-my-zsh/custom/plugins/$2"
  fi
}

setup_git_config() {
  if [ ! -f "$HOME/.gitconfig" ]; then
    git config --global init.defaultBranch main
    git config --global user.email "$carrier_pigeon"
    git config --global user.name "$user_name"
    git config --global pull.rebase true
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

install_swamp() {
  if ! command -v swamp &>/dev/null; then
    if [[ "$CPU" == "arm" ]]; then
      curl -L "https://github.com/otto-de/swamp/releases/download/v0.11.0-otto/swamp-darwin-amd64" >/opt/homebrew/bin/swamp
      chmod +x /opt/homebrew/bin/swamp
    else
      curl -L "https://github.com/otto-de/swamp/releases/download/v0.11.0-otto/swamp-darwin-amd64" >/usr/local/bin/swamp
      chmod +x /usr/local/bin/swamp
    fi
  fi
}

###

install_python() {
  brew_install python
  brew_install pyenv

  if [[ ! "$(find_str_in_zshrc pyenv)" ]]; then
    append_zshrc 'eval "$(pyenv init -)"'
  fi
}

install_gui_tools() {
  brew_cask_install docker
  brew_cask_install iterm2
  brew_cask_install intellij-idea-ce
  brew_cask_install pycharm-ce
  brew_cask_install lulu
  brew_cask_install keeweb

  brew_cask_install firefox
  brew_cask_install coconutbattery
  brew_cask_install zoom
}

install_leiningen() {
  brew_install leiningen

  if [ ! -d "$HOME/.lein" ]; then
    mkdir "$HOME/.lein"
    cp "$SCRIPT_DIR/../resources/leiningen/profiles.clj" "$HOME/.lein"
  fi

  if [[ ! "$(find_str_in_zshrc LEIN_USE_BOOTCLASSPATH)" ]]; then
    append_zshrc 'export LEIN_USE_BOOTCLASSPATH=no'
  fi
}

set_jdk_path() {
  if [[ ! "$CPU" == 'arm' && ! "$(find_str_in_zshrc openjdk@11/bin)" ]]; then
    append_zshrc 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"'
  fi
}

install_jenv() {
  brew_install jenv
  if [[ ! "$CPU" == "arm" ]]; then
    jenv add /usr/local/opt/openjdk@11/
  fi

  if [[ ! "$(find_str_in_zshrc jenv)" ]]; then
    append_zshrc 'eval "$(jenv init -)"'
  fi
}

install_jvm() {
  #java
  brew_install openjdk@11
  brew_install gradle
  brew_install mvn
  install_jenv
  set_jdk_path

  #clojure
  brew_install clojure
  install_leiningen
}

install_vim() {
  brew_install vim
  if [ ! -f "$HOME/.vimrc" ]; then
    cp "$SCRIPT_DIR/../resources/vim/.vimrc" "$HOME/.vimrc"
  fi
}

install_essential_tools() {
  brew_install curl
  brew_install wget
  brew_install jq
  brew_install node
  brew_install htop
  brew_install watch
  brew_install tree
  brew_install tldr
  brew_install the_silver_searcher
  brew_install postgresql
  brew_install mas
  brew_install shellcheck
  brew install xdotool
  brew_install shfmt
}

install_yubikey_tools() {
  brew_install ykman

  if ! command -v lmfa &>/dev/null; then
    if [[ "$CPU" == "arm" ]]; then
      cp "$SCRIPT_DIR/../resources/yubikey/lmfa" /opt/homebrew/bin/lmfa
    else
      cp "$SCRIPT_DIR/../resources/yubikey/lmfa" /usr/local/bin/lmfa
    fi
  fi
}

install_cargo() {
  if ! command -v cargo &>/dev/null; then
    curl https://sh.rustup.rs -sSf | sh
  fi
}

install_rust() {
  brew_install rustup
  install_cargo
}

install_awscli_v1() {
  brew list awscli@1 || brew install awscli@1 && brew pin awscli@1
  if [[ ! "$CPU" == 'arm' && ! "$(find_str_in_zshrc awscli@1)" ]]; then
    append_zshrc 'export PATH="/usr/local/opt/awscli@1/bin:$PATH"'
  else
    brew link awscli@1 --force
  fi
}

install_aws_config() {
  if [ ! -d "$HOME/.aws" ]; then
    mkdir -p "$HOME/.aws"
    append_line_to_file "[default]" "$HOME/.aws/config"
    append_line_to_file "region = eu-central-1" "$HOME/.aws/config"
  fi
}

install_aws_tools() {
  install_terraform
  install_swamp
  install_awscli_v1
  install_aws_config
}

install_tig() {
  brew_install tig
  if [ ! -d "$HOME/.tigrc" ]; then
    cp "$SCRIPT_DIR/../resources/tig/.tigrc" "$HOME/.tigrc"
  fi
}

install_git() {
  brew_install git
  brew_install openssh
  setup_git_config
  setup_ssh_config
  install_tig
}

install_fzf_plugin() {
  brew_install fzf
  if [[ ! "$(find_str_in_zshrc fzf.zsh)" ]]; then
    $(brew --prefix)/opt/fzf/install
  fi
}

install_zsh_config() {
  if [ ! -d "$HOME/.config/zsh/custom_config/" ]; then
    mkdir -p "$HOME/.config/zsh/custom_config/"
  fi
}

install_zsh-syntax-highlighting_plugin() {
  install_zsh_plugin zsh-users zsh-syntax-highlighting
  if [[ ! "$(find_str_in_zshrc zsh-syntax-highlighting.zsh)" ]]; then
    append_zshrc 'source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"'
    append_zshrc 'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)'
    append_zshrc "ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')"
  fi
}

install_zsh_tools() {
  install_zsh_config
  #
  install_ohmyzsh
  setup_ohmyzsh_config
  #
  install_zsh-syntax-highlighting_plugin
  install_zsh_plugin zsh-users zsh-completions
  install_zsh_plugin zsh-users zsh-autosuggestions
  install_zsh_plugin chrissicool zsh-256color
  install_zsh_plugin joel-porquet zsh-dircolors-solarized
  install_zsh_plugin agkozak zsh-z
  install_fzf_plugin
}

install_tmux_plugins_manager() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
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
  #
  brew_install reattach-to-user-namespace
  brew_install urlview
  brew_install extract_url
  #
  install_tmux_plugins_manager
}

install_xcode() {
  # Download and install Command Line Tools
  if [[ ! -x /usr/bin/gcc ]]; then
    xcode-select --install
  fi
}

install_home_brew() {
  # Download and install Homebrew
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ "$CPU" == 'arm' && ! "$(find_str_in_zshrc homebrew)" ]]; then
    append_zshrc 'export PATH="/opt/homebrew/bin:$PATH"'
  fi
}

install_languages() {
  install_python
  install_rust
  install_jvm
}

install_mas() {
  if [[ ! "$(mas list | grep $1)" ]]; then
    mas install "$1"
  fi
}

install_from_appstore() {
  #Magnet
  install_mas 441258766
  #Boop
  install_mas 1518425043
  #AdGuard for Safari
  install_mas 1440147259
  #KeeWeb Connect
  install_mas 1565748094
}

############################ START ####################################
#
install_xcode
install_home_brew

###
install_essential_tools

###
install_zsh_tools
install_tmux_tools
install_git
install_vim

###
install_languages

###
install_yubikey_tools
install_aws_tools

###
install_gui_tools

##Appstore
install_from_appstore
