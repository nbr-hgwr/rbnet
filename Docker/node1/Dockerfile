FROM centos:7

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.7.3"

# 必要なパッケージをインストール
RUN yum -y update
RUN yum -y install git gcc gcc-c++ tar openssl openssl-devel readline-devel zlib zlib-devel bzip2 iproute tcpdump wireshark
RUN yum clean all

# rubyとbundleをダウンロード
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

RUN git clone https://github.com/nbr-hgwr/rbshark.git

# コマンドでrbenvが使えるように設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

# rubyとrailsをインストール
RUN source /etc/profile.d/rbenv.sh; rbenv install ${ruby_ver}; rbenv global ${ruby_ver}