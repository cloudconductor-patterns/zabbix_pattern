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

metadata_file = os.path.join(pattern_root, 'metadata.yml')

metadata = yaml.load(file(metadata_file))

pattern_name = metadata['name']


def mkdirs(path):
    if not os.path.exists(path):
        os.makedirs(path)


def log_dir():
    path = os.path.join(pattern_root, 'logs')
    mkdirs(path)
    return path


def roles_dir():
    return os.path.join(pattern_root, 'roles')


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


def file_open(path, mode):
    return open(path, mode)


def create_chefsolo_config_file(role):
    filecache_dir = os.path.join(pattern_root, 'tmp', 'cache')
    mkdirs(filecache_dir)

    config_file = os.path.join(pattern_root, 'solo.rb')

    log_file = os.path.join(
        log_dir(), pattern_name + '_' + role + '_chef-solo.log')
    cookbooks_dir = os.path.join(pattern_root, 'cookbooks')
    site_cookbooks_dir = os.path.join(pattern_root, 'site-cookbooks')

    fo = file_open(config_file, 'w')
    fo.write('ssl_verify_mode :verify_peer\n')
    fo.write("role_path '" + roles_dir() + "'\n")
    fo.write('log_level :info\n')
    fo.write("log_location '" + log_file + "'\n")
    fo.write("file_cache_path '" + filecache_dir + "'\n")

    cookbook_path = "cookbook_path ['" + \
        cookbooks_dir + "', '" + site_cookbooks_dir + "']"
    fo.write(cookbook_path)

    fo.close()

    return config_file


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


def consul_kv_keys(prefix):
    import consul
    c = consul.Consul()
    index, data = c.kv.get(prefix, token=token_key(), keys=True)
    return data


def read_parameters():
    try:
        ret = consul_kv_get('cloudconductor/parameters')
    except Exception as e:
        logging.warn("%s: %s", type(e), e.message)
        ret = {}
    return ret


def pattern(data, name):
    return data['cloudconductor']['patterns'][name]


def read_servers():
    servers = {}
    prefix = 'cloudconductor/servers/'

    try:
        keys = consul_kv_keys(prefix)

        for key in keys:
            hostname = key[len(prefix):]
            info = consul_kv_get(key)
            servers[hostname] = info

    except Exception as e:
        logging.warn("%s: %s", type(e), e.message)
        servers = {}

    return servers


def deep_copy(dic0):
    if not isinstance(dic0, dict):
        return dic0

    return dict(dic0.items())


def deep_merge(dic0, dic1):
    if not isinstance(dic1, dict):
        return dic1

    result = deep_copy(dic0)
    for key, value in dic1.iteritems():
        if key in result and isinstance(result[key], dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = deep_copy(value)

    return result


def create_chefsolo_node_file(role, event):
    node_file = os.path.join(pattern_root, 'node.json')

    parameters = read_parameters()

    if event != 'setup':
        data = deep_merge(
            parameters, pattern(parameters, pattern_name)['user_attributes'])
        data['cloudconductor']['servers'] = read_servers()
        parameters = data

    parameters['run_list'] = ['role[' + role + '_' + event + ']']

    fo = file_open(node_file, 'w')
    fo.write(json.dumps(parameters))

    fo.close()

    return node_file


def run_chefsolo(role, event):
    config_file = create_chefsolo_config_file(role)
    node_file = create_chefsolo_node_file(role, event)

    cmd = 'cd ' + pattern_root + '; berks vendor ./cookbooks'
    result = system(cmd)
    if result == 0:
        logging.info('run berks successfully.')
    else:
        logging.warn('failed to run berks.')

    cmd = 'chef-solo -c ' + config_file + ' -j ' + node_file
    result = system(cmd)
    if result == 0:
        logging.info('run chef-solo successfully.')

    return result


def execute_chef(roles, event):
    result = 0

    roles.append('all')

    for role in roles:
        role_file = os.path.join(roles_dir(), role + "_" + event + ".json")
        if os.path.exists(role_file):
            logging.info('execute chef with [%s].', role)

            result = run_chefsolo(role, event)

            if result == 0:
                logging.info('finished successfully.')
            else:
                logging.error('finished abnormally.')
                break

        else:
            logging.info('role file [%s] does not exist. skipped.', role_file)

    return result


def execute(roles, event):
    result = 0

    if event == 'spec':
        result = execute_serverspec(roles)
    else:
        result = execute_chef(roles, event)

    return result

if __name__ == '__main__':
    import sys
    argvs = sys.argv
    argc = len(argvs)

    roles = argvs[1].split(',')
    event = argvs[2]

    LOG_FILE = os.path.join(log_dir(), 'event-handler.log')
    logging.basicConfig(filename=LOG_FILE,
                        format='[%(asctime)s] %(levelname)s: %(message)s',
                        level=logging.DEBUG)

    ret = execute(roles, event)
    exit(ret)
