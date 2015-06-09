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

if [ "${CHEF_ENV_FILE}" == "" ]; then
  CHEF_ENV_FILE="/etc/profile.d/chef.sh"
fi

run() {
  output="$("$@" 2>&1)"
  status="$?"
}

install_chef() {
  run which chef-solo
  if [ $status -ne 0 ]; then
    echo "install chef."
    curl -L http://www.opscode.com/chef/install.sh | bash
  fi
}

set_ruby_path() {
  run which ruby
  if [ $status -ne 0 ]; then
    if [[ -d /opt/chefdk ]] && [[ -x /opt/chefdk/embedded/bin/ruby ]]; then
      ruby_home=/opt/chefdk/embedded
    elif [[ -d /opt/chef ]] && [[ -x /opt/chef/embedded/bin/ruby ]]; then
      ruby_home=/opt/chef/embedded
    fi

    echo "export PATH=\$PATH:${ruby_home}/bin" > ${CHEF_ENV_FILE}
    export PATH=${ruby_home}/bin:${PATH}
  fi
}

install_berkshelf() {
  set_ruby_path

  run bash -c "gem list | grep berkshelf"
  if [ $status -ne 0 ]; then
    yum install -y make gcc gcc-c++ autoconf
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

install_chef
install_berkshelf
install_serverspec

setup_python_env ./lib/python-packages.txt

#ruby ./lib/event_handler.rb "${1}" "${2}"
python ./lib/event_handler.py "${1}" "${2}"
