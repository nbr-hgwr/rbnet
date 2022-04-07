#!/bin/bash

RBENV_INSTALL_DEST_DIR=/usr/local/rbenv
COMMON_BASH_SETTING_FILE=/etc/profile

echo "install gcc..."
sudo yum -y install gcc

echo "install openssl-devel..."
sudo yum -y install openssl-devel

echo "instal readline-devel..."
sudo yum install -y readline-devel

which git
if [ $? -ne 0 ]
then
  echo "install git..."
  sudo yum -y install git
fi

echo "download rbenv..."
sudo git clone https://github.com/sstephenson/rbenv.git ${RBENV_INSTALL_DEST_DIR}

# add rbenv path To $PATH
echo "append rbenv path info To ${COMMON_BASH_SETTING_FILE}..."
echo "export RBENV_ROOT=\"${RBENV_INSTALL_DEST_DIR}\"" >> ${COMMON_BASH_SETTING_FILE}
echo 'export PATH="${RBENV_ROOT}/bin:$PATH"' >> ${COMMON_BASH_SETTING_FILE}
echo 'eval "$(rbenv init -)"' >> ${COMMON_BASH_SETTING_FILE}

# ${COMMON_BASH_SETTING_FILE} reload
echo "${COMMON_BASH_SETTING_FILE} reload"
source ${COMMON_BASH_SETTING_FILE}

echo "download rbenv plugin(ruby-build)..."
git clone https://github.com/sstephenson/ruby-build.git ${RBENV_INSTALL_DEST_DIR}/plugins/ruby-build

# install ruby
echo "ruby install..."
rbenv install -v 3.1.1

rbenv global 3.1.1

rbenv rehash

# set rbenv owner
chown -R vagrant:vagrant ${RBENV_INSTALL_DEST_DIR}