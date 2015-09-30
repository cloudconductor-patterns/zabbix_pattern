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

if [ "${PACKAGE_LIST}" == "" ]; then
  PACKAGE_LIST='/opt/cloudconductor/python-packages.txt'
fi

run() {
  [[ ! "$-" =~ e ]] || e=1
  [[ ! "$-" =~ E ]] || E=1
  [[ ! "$-" =~ T ]] || T=1

  set +e
  set +E
  set +T

  output="$("$@" 2>&1)"
  status="$?"
  oldIFS=$IFS
  IFS=$'\n' lines=($output)

  IFS=$oldIFS
  [ -z "$e" ] || set -e
  [ -z "$E" ] || set -E
  [ -z "$T" ] || set -T
}

pyenv_activate() {
  work_dir=$(pwd)

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

  run which virtualenv
  if [ $status -ne 0 ] ; then
    run pip install virtualenv
    if [ $status -ne 0 ] ; then
      echo "$output" >&2
      return 1
    fi
  fi

  if [ ! -f ${work_dir}/.vent/bin/activate ] ; then
    run bash -c "cd ${work_dir} && virtualenv --no-site-packages .venv"
    if [ $status -ne 0 ] ; then
      echo "$output" >&2
      return 1
    fi
  fi

  source .venv/bin/activate

  run pip install -r ${PACKAGE_LIST}
  if [ $status -ne 0 ] ; then
    echo "$output" >&2
    deactivate
    return 1
  fi
}

python_exec() {
  pyenv_activate || return $?

  run python $@
  if [ $status -ne 0 ] ; then
    echo "$output" >&2
    deactivate
    return 1
  fi
  echo "$output"

  deactivate
}
