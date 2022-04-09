#!/bin/bash

RBENV_INSTALL_DEST_DIR=/usr/local/rbenv
COMMON_BASH_SETTING_FILE=/etc/profile

sudo yum -y install gcc openssl-devel readline-devel git tcpdump wireshark

sudo git clone https://github.com/sstephenson/rbenv.git ${RBENV_INSTALL_DEST_DIR}

echo "append rbenv path info To ${COMMON_BASH_SETTING_FILE}..."
echo "export RBENV_ROOT=\"${RBENV_INSTALL_DEST_DIR}\"" >> ${COMMON_BASH_SETTING_FILE}
echo 'export PATH="${RBENV_ROOT}/bin:$PATH"' >> ${COMMON_BASH_SETTING_FILE}
echo 'eval "$(rbenv init -)"' >> ${COMMON_BASH_SETTING_FILE}

source ${COMMON_BASH_SETTING_FILE}

git clone https://github.com/sstephenson/ruby-build.git ${RBENV_INSTALL_DEST_DIR}/plugins/ruby-build

# install ruby
rbenv install -v 3.1.1
rbenv global 3.1.1
rbenv rehash

# set rbenv owner
chown -R vagrant:vagrant ${RBENV_INSTALL_DEST_DIR}