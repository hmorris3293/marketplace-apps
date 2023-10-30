#!/bin/bash
set -e
trap "cleanup $? $LINENO" EXIT

# determine distro
export distro=$(cat /etc/os-release | sed -n 's/^NAME="\(.*\)"/\1/p' | awk '{print $1}' | sed 's/.*/\L&/')

# git repo
export GIT_REPO="https://github.com/akamai-compute-marketplace/marketplace-apps.git"
export WORK_DIR="/root/marketplace-apps" # moved to root dir because cpanel install will remove anything in tmp
export MARKETPLACE_APP="apps/linode-marketplace-cpanel-$distro"

# enable logging
exec > >(tee /dev/ttyS0 /var/log/stackscript.log) 2>&1
echo $distro 
echo $MARKETPLACE_APP
function cleanup {
  if [ -d "${WORK_DIR}" ]; then
    rm -rf ${WORK_DIR}
  fi

}

function run {
  # install dependancies
  export DEBIAN_FRONTEND=non-interactive
  apt-get update
  apt-get install -y git python3 python3-pip

  # clone repo and set up ansible environment
  git -C /root clone ${GIT_REPO}
  # for a single testing branch
  # git -C /root clone --single-branch --branch ${BRANCH} ${GIT_REPO}

  # venv
  cd ${WORK_DIR}/${MARKETPLACE_APP}
  pip3 install virtualenv
  python3 -m virtualenv env
  source env/bin/activate
  pip install pip --upgrade
  pip install -r requirements.txt
  ansible-galaxy install -r collections.yml

  # run playbook
  ansible-playbook -v site.yml
}

function installation_complete {
  echo "Installation Complete"
}
# main
run && installation_complete
cleanup
