#!/bin/bash
set -e
set -x

CODE_REPO_LOCATION=${HOME}/.mac_provisoning

main() {
  if [ ! -d "$CODE_REPO_LOCATION" ]; then
    mkdir "$CODE_REPO_LOCATION"
    git clone https://github.com/minhtuannguyen/mac_provisioning.git "$CODE_REPO_LOCATION"
    printf "alias macpro='%s/scripts/provisioning.sh'\n" "$CODE_REPO_LOCATION" >>"$HOME/.zshrc"
    printf "alias macpro-update='cd %s && git pull && cd -'\n" "$CODE_REPO_LOCATION" >>"$HOME/.zshrc"
  fi
}

main
