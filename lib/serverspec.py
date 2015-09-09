#!/usr/bin/env python
# -*- coding: utf-8 -*-
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

import os
import logging
import json
import yaml

file_dir = os.path.dirname(__file__)
dir_path = os.path.join(file_dir, '../')
pattern_root = os.path.abspath(dir_path)


def mkdirs(path):
    if not os.path.exists(path):
        os.makedirs(path)


def log_dir():
    path = os.path.join(pattern_root, 'logs')
    mkdirs(path)
    return path


def system(cmd):
    import subprocess
    ret = subprocess.call(cmd, shell=True)
    return ret


def events():
    ret = ['configure']

    parameters = read_parameters()
    if 'cloudconductor' in parameters and \
            parameters['cloudconductor'] is not None and \
            'applications' in parameters['cloudconductor'] and \
            parameters['cloudconductor']['applications'] is not None:
        ret.append('deploy')

    return ret


def execute_serverspec(roles):
    ret = 0

    roles.insert(0, 'all')
    event_list = events()

    test_root = os.path.join(pattern_root, 'serverspec')
    spec_dir = os.path.join(test_root, 'spec')

    for role in roles:
        for event in event_list:
            spec_file = os.path.join(
                spec_dir, role, role + '_' + event + '_spec.rb')
            if os.path.exists(spec_file):
                logging.info('execute serverspec with [%s].', spec_file)

                cmd = 'cd ' + test_root + \
                    '; rake spec[' + role + ',' + event + ']'
                result = system(cmd)

                if result == 0:
                    logging.info('finished successfully.')
                else:
                    logging.error('finished abnormally.')
                    ret = 1

            else:
                logging.info(
                    'spec file [%s] does not exist. skipped.', spec_file)

    return ret


def env(name):
    return os.environ.get(name)


def token_key():
    return env('CONSUL_SECRET_KEY')


def consul_kv_get(key):
    import consul
    c = consul.Consul()
    index, data = c.kv.get(key, token=token_key())
    obj = json.loads(data['Value'])
    return obj


def read_parameters():
    try:
        ret = consul_kv_get('cloudconductor/parameters')
    except Exception as e:
        logging.warn("%s: %s", type(e), e.message)
        ret = {}
    return ret


if __name__ == '__main__':
    import sys
    argvs = sys.argv
    argc = len(argvs)

    roles = argvs[1].split(',')

    LOG_FILE = os.path.join(log_dir(), 'event-handler.log')
    logging.basicConfig(filename=LOG_FILE,
                        format='[%(asctime)s] %(levelname)s: %(message)s',
                        level=logging.DEBUG)

    ret = execute_serverspec(roles)
    exit(ret)
