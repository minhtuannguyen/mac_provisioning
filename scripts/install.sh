#!/bin/bash
set -e

CODE_REPO_LOCATION=${HOME}/.mac_provisoning

main() {
  if [ ! -d "$CODE_REPO_LOCATION" ]; then
    mkdir "$CODE_REPO_LOCATION"
    git clone https://github.com/minhtuannguyen/mac_provisioning.git "$CODE_REPO_LOCATION"
    read -p "Enter your email:" user_email
    read -p "Enter your name:" user_name

    printf "alias macpro='%s/scripts/provisioning.sh %s %s'\n" "$CODE_REPO_LOCATION" "$user_email" "$user_name" >>"$HOME/.zshrc"
    printf "alias macpro-update='cd %s && git pull && cd -'\n" "$CODE_REPO_LOCATION" >>"$HOME/.zshrc"

    echo "mac_provisioning is installed!"
  fi
}

main
