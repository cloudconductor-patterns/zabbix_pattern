#!/bin/sh
# Copyright 2014-2015 TIS Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

RUBY_VERSION=2.3.0
RUBY_URL="https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%\.*}/ruby-${RUBY_VERSION}.tar.gz"

if [ "${CHEF_ENV_FILE}" == "" ]; then
  CHEF_ENV_FILE="/etc/profile.d/chef.sh"
fi

run() {
  output="$("$@" 2>&1)"
  status="$?"
}

install_ruby() {
  run which ruby
  if [ $status -ne 0 ]; then
    echo "install ruby"
    yum install -y make gcc gcc-c++ autoconf openssl-devel
    curl --retry 5 -s ${RUBY_URL} > /tmp/ruby-${RUBY_VERSION}.tar.gz
    tar zxvf /tmp/ruby-${RUBY_VERSION}.tar.gz -C /tmp
    cd /tmp/ruby-${RUBY_VERSION}
    ./configure
    make
    make install
  fi
}

set_ruby_path() {
  run which ruby
  if [ $status -ne 0 ]; then
    if [[ -x /usr/local/bin/ruby ]]; then
      ruby_path=/usr/local/bin
    fi

    echo "export PATH=\$PATH:${ruby_path}" > ${CHEF_ENV_FILE}
    export PATH=${PATH}:${ruby_path}
  fi
}

install_chef() {
  set_ruby_path

  run bash -c "gem list | grep chef"
  if [ $status -ne 0 ]; then
    gem install chef
  fi
}

install_berkshelf() {
  set_ruby_path

  run bash -c "gem list | grep berkshelf"
  if [ $status -ne 0 ]; then
    gem install berkshelf
  fi
}

install_serverspec() {
  set_ruby_path

  run bash -c "gem list | grep serverspec"
  if [ $status -ne 0 ]; then
    gem install serverspec
  fi
}

setup_python_env() {
  PACKAGE_LIST=$1

  run which python
  if [ $status -ne 0 ] ; then
    run yum install -y python
    if [ $status -ne 0 ] ; then
      echo "$output" >&2
      return 1
    fi
  fi

  run which pip
  if [ $status -ne 0 ] ; then
    run bash -c "curl -kL https://bootstrap.pypa.io/get-pip.py | python"
    if [ $status -ne 0 ] ; then
      echo "$output" >&2
      return 1
    fi
  fi

  run pip install -r ${PACKAGE_LIST}
  if [ $status -ne 0 ] ; then
    echo "$output" >&2
    deactivate
    return 1
  fi
}

install_ruby
install_chef
install_berkshelf
install_serverspec

setup_python_env ./lib/python-packages.txt
