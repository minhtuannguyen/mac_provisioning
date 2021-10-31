#!/bin/bash
set -e
set -x

CODE_REPO_LOCATION=${HOME}/.mac_provisoning

main() {
  if [ ! -d "$CODE_REPO_LOCATION" ]; then
    mkdir "$CODE_REPO_LOCATION"
    git clone https://github.com/minhtuannguyen/mac_provisioning.git "$CODE_REPO_LOCATION"
    printf "\n%s\n" "alias macpro='""$CODE_REPO_LOCATION""/scripts/provisioning.sh" >>"$HOME/.zshrc"
  fi
}

main
