# -*- coding: utf-8 -*-
# Copyright 2014 TIS Inc.
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
require_relative '../../lib/event_handler.rb'

pattern_path = File.expand_path('../../../', __FILE__)
describe CloudConductorPattern::EventHandler do
  before do
    allow(Dir).to receive(:exist?).and_return(true)
    allow(FileUtils).to receive(:mkdir_p)
    dummy_logger = double(:logger, info: nil)
    allow(CloudConductorPattern::PatternLogger).to receive(:logger).with(
      "#{pattern_path}/logs/event-handler.log"
    ).and_return(dummy_logger)
  end

  describe '#initialize' do
    it 'creates and returns new instance' do
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      expect(event_handler.instance_variable_get('@logger')).not_to be_nil
      expect(event_handler.instance_variable_get('@pattern_name')).to eq('zabbix_pattern')
      expect(event_handler.instance_variable_get('@pattern_dir')).to eq("#{pattern_path}")
      expect(event_handler.instance_variable_get('@roles')).to eq(%w(web ap db))
    end
  end

  describe '#execute' do
    it 'executes rspec' do
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      allow(event_handler).to receive(:execute_serverspec)
      event_handler.execute('spec')
    end

    it 'executes chef' do
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      allow(event_handler).to receive(:execute_chef).with('setup')
      event_handler.execute('setup')
    end
  end

  describe '#execute_chef' do
    it 'executes chef' do
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/roles/web_setup.json"
      ).and_return(true)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/roles/ap_setup.json"
      ).and_return(false)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/roles/db_setup.json"
      ).and_return(true)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/roles/all_setup.json"
      ).and_return(false)
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      allow(event_handler).to receive(:create_chefsolo_config_file).with('web')
      allow(event_handler).to receive(:create_chefsolo_node_file).with('web', 'setup')
      allow(event_handler).to receive(:create_chefsolo_config_file).with('db')
      allow(event_handler).to receive(:create_chefsolo_node_file).with('db', 'setup')
      allow(event_handler).to receive(:run_chefsolo)
      event_handler.send(:execute_chef, 'setup')
      expect(event_handler).not_to receive(:create_chefsolo_config_file).with('ap')
      expect(event_handler).not_to receive(:create_chefsolo_node_file).with('ap', 'setup')
      expect(event_handler).not_to receive(:create_chefsolo_config_file).with('all')
      expect(event_handler).not_to receive(:create_chefsolo_node_file).with('all', 'setup')
    end
  end

  describe '#execute_serverspec' do
    it 'executes serverspec in configure phase' do
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      allow(event_handler).to receive(:deploy?).and_return(false)
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/serverspec/spec/web/web_configure_spec.rb"
      ).and_return(true)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/serverspec/spec/db/db_configure_spec.rb"
      ).and_return(true)
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}/serverspec; rake spec[web,configure]").and_return(true)
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}/serverspec; rake spec[db,configure]").and_return(true)
      event_handler.send(:execute_serverspec)
    end

    it 'executes serverspec in deploy phase' do
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      allow(event_handler).to receive(:deploy?).and_return(true)
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/serverspec/spec/web/web_configure_spec.rb"
      ).and_return(true)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/serverspec/spec/db/db_configure_spec.rb"
      ).and_return(true)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/serverspec/spec/web/web_deploy_spec.rb"
      ).and_return(true)
      allow(File).to receive(:exist?).with(
        "#{pattern_path}/serverspec/spec/db/db_deploy_spec.rb"
      ).and_return(true)
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}/serverspec; rake spec[web,configure]").and_return(true)
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}/serverspec; rake spec[web,deploy]").and_return(true)
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}/serverspec; rake spec[db,configure]").and_return(true)
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}/serverspec; rake spec[db,deploy]").and_return(true)
      event_handler.send(:execute_serverspec)
    end
  end

  describe '#deploy?' do
    it 'returns true' do
      dummy_parameter = {
        cloudconductor: {
          applications: {
          }
        }
      }
      allow(CloudConductorUtils::Consul).to receive(:read_parameters).and_return(dummy_parameter)
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      result = event_handler.send(:deploy?)
      expect(result).to eq(true)
    end

    it 'returns false' do
      allow(CloudConductorUtils::Consul).to receive(:read_parameters).and_return({})
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      result = event_handler.send(:deploy?)
      expect(result).to eq(false)
    end
  end

  describe '#create_chefsolo_config_file' do
    it 'creates config file' do
      dummy_file = Object.new
      allow(dummy_file).to receive(:write).with("ssl_verify_mode :verify_peer\n")
      allow(dummy_file).to receive(:write).with("role_path '#{pattern_path}/roles'\n")
      allow(dummy_file).to receive(:write).with("log_level :info\n")
      allow(dummy_file).to receive(:write).with("log_location '#{pattern_path}/logs/zabbix_pattern_web_chef-solo.log'\n")
      allow(dummy_file).to receive(:write).with("file_cache_path '#{pattern_path}/tmp/cache'\n")
      allow(dummy_file).to receive(:write).with("cookbook_path ['#{pattern_path}/cookbooks', '#{pattern_path}/site-cookbooks']\n")
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      allow(File).to receive(:open).with(
        "#{pattern_path}/solo.rb",
        'w'
      ).and_yield(dummy_file)
      event_handler.send(:create_chefsolo_config_file, 'web')
    end
  end

  describe '#create_chefsolo_node_file' do
    it 'creates node file in case of setup' do
      dummy_parameter = {
        cloudconductor: {
          patterns: {
            zabbix_pattern: {
              user_attributes: {
                key1: 'value1',
                key2: {
                  key3: 'value3'
                }
              }
            }
          }
        }
      }
      allow(CloudConductorUtils::Consul).to receive(:read_parameters).and_return(dummy_parameter)
      expected_data = {
        cloudconductor: {
          patterns: {
            zabbix_pattern: {
              user_attributes: {
                key1: 'value1',
                key2: {
                  key3: 'value3'
                }
              }
            }
          }
        },
        run_list: [
          'role[web_setup]'
        ]
      }
      allow(File).to receive(:write).with(
        "#{pattern_path}/node.json",
        expected_data.to_json
      )
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      event_handler.send(:create_chefsolo_node_file, 'web', 'setup')
    end

    it 'creates node file in case of not setup' do
      dummy_parameter = {
        cloudconductor: {
          patterns: {
            zabbix_pattern: {
              user_attributes: {
                key1: 'value1',
                key2: {
                  key3: 'value3'
                }
              }
            }
          }
        }
      }
      dummy_servers = {
        testserver: {
          ip: '192.168.0.1'
        }
      }
      allow(CloudConductorUtils::Consul).to receive(:read_parameters).and_return(dummy_parameter)
      allow(CloudConductorUtils::Consul).to receive(:read_servers).and_return(dummy_servers)
      expected_data = {
        cloudconductor: {
          patterns: {
            zabbix_pattern: {
              user_attributes: {
                key1: 'value1',
                key2: {
                  key3: 'value3'
                }
              }
            }
          },
          servers: {
            testserver: {
              ip: '192.168.0.1'
            }
          }
        },
        key1: 'value1',
        key2: {
          key3: 'value3'
        },
        run_list: [
          'role[web_configure]'
        ]
      }
      allow(File).to receive(:write).with(
        "#{pattern_path}/node.json",
        expected_data.to_json
      )
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      result = event_handler.send(:create_chefsolo_node_file, 'web', 'configure')
      expect(result).to eq("#{pattern_path}/node.json")
    end
  end

  describe '#run_chefsolo' do
    it 'runs chef-solo' do
      event_handler = CloudConductorPattern::EventHandler.new('web,ap,db')
      expect(event_handler).to receive(:system)
        .with("cd #{pattern_path}; berks vendor ./cookbooks").and_return(true).ordered
      expect(event_handler).to receive(:system)
        .with("chef-solo -c #{pattern_path}/solo.rb -j #{pattern_path}/node.json").and_return(true).ordered
      event_handler.send(:run_chefsolo)
    end
  end
end
