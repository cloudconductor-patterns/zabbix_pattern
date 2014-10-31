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

require 'yaml'
require 'json'
require 'active_support'
require 'cloud_conductor_utils/consul'
require_relative './pattern_logger'

module CloudConductorPattern
  # rubocop: disable ClassLength
  class EventHandler
    def initialize(node_role)
      metadata_file = File.join(File.expand_path('../', File.dirname(__FILE__)), 'metadata.yml')
      @pattern_name = YAML.load_file(metadata_file)['name']
      @pattern_dir = File.expand_path('../', File.dirname(__FILE__))
      log_dir = File.join(@pattern_dir, 'logs')
      FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
      log_filename = File.join(log_dir, 'event-handler.log')
      @logger = CloudConductorPattern::PatternLogger.logger(log_filename)
      @roles = node_role.split(',')
    end

    def execute(event)
      if event == 'spec'
        execute_serverspec
      else
        execute_chef(event)
      end
    end

    private

    def execute_chef(event)
      roles_dir = File.join(@pattern_dir, 'roles')
      @roles << 'all'
      @roles.each do |role|
        role_file = "#{roles_dir}/#{role}_#{event}.json"
        if File.exist?(role_file)
          @logger.info("execute chef with [#{role_file}].")
          begin
            create_chefsolo_config_file(role)
            create_chefsolo_node_file(role, event)
            run_chefsolo
            @logger.info('finished successfully.')
          rescue => exception
            @logger.error("finished abnormally. #{exception.message}")
            raise
          end
        else
          @logger.info("role file [#{role_file}] does not exist. skipped.")
        end
      end
    end

    # rubocop: disable MethodLength
    def execute_serverspec
      has_error = false
      @roles.unshift('all')
      events = deploy? ? %w( configure deploy ) : %w( configure )
      spec_root_dir = File.join(@pattern_dir, 'serverspec')
      spec_dir = File.join(spec_root_dir, 'spec')
      @roles.each do |role|
        events.each do |event|
          spec_file = "#{spec_dir}/#{role}/#{role}_#{event}_spec.rb"
          if File.exist?(spec_file)
            @logger.info("execute serverspec with [#{spec_file}].")
            spec_result = system("cd #{spec_root_dir}; rake spec[#{role},#{event}]")
            if spec_result
              @logger.info('finished successfully.')
            else
              @logger.error('finished abnormally. ')
              has_error = true
            end
          else
            @logger.info("spec file [#{spec_file}] does not exist. skipped.")
          end
        end
      end
      fail if has_error
    end
    # rubocop: enable MethodLength

    def deploy?
      parameters = CloudConductorUtils::Consul.read_parameters
      !(parameters[:cloudconductor].nil? || parameters[:cloudconductor][:applications].nil?)
    end

    def create_chefsolo_config_file(role)
      roles_dir = File.join(@pattern_dir, 'roles')
      filecache_dir = File.join(@pattern_dir, 'tmp', 'cache')
      FileUtils.mkdir_p(filecache_dir) unless Dir.exist?(filecache_dir)
      chefsolo_config_file = File.join(@pattern_dir, 'solo.rb')
      chefsolo_log_file = File.join(@pattern_dir, 'logs', "#{@pattern_name}_#{role}_chef-solo.log")
      cookbooks_dir = File.join(@pattern_dir, 'cookbooks')
      site_cookbooks_dir = File.join(@pattern_dir, 'site-cookbooks')
      File.open(chefsolo_config_file, 'w') do |file|
        file.write("ssl_verify_mode :verify_peer\n")
        file.write("role_path '#{roles_dir}'\n")
        file.write("log_level :info\n")
        file.write("log_location '#{chefsolo_log_file}'\n")
        file.write("file_cache_path '#{filecache_dir}'\n")
        file.write("cookbook_path ['#{cookbooks_dir}', '#{site_cookbooks_dir}']\n")
      end
    end

    def create_chefsolo_node_file(role, event)
      chefsolo_node_file = File.join(@pattern_dir, 'node.json')
      parameters = CloudConductorUtils::Consul.read_parameters
      if event != 'setup'
        parameters.deep_merge!(parameters[:cloudconductor][:patterns][@pattern_name.to_sym][:user_attributes])
        parameters[:cloudconductor][:servers] = CloudConductorUtils::Consul.read_servers
      end
      parameters[:run_list] = ["role[#{role}_#{event}]"]
      File.write(chefsolo_node_file, parameters.to_json)
      @logger.info('created chefsolo_node_file successfully.')
      chefsolo_node_file
    end

    def run_chefsolo
      chefsolo_config_file = File.join(@pattern_dir, 'solo.rb')
      chefsolo_node_file = File.join(@pattern_dir, 'node.json')
      berks_result = system("cd #{@pattern_dir}; berks vendor ./cookbooks")
      if berks_result
        @logger.info('run berks successfully.')
      else
        @logger.warn('failed to run berks.')
      end
      chef_solo_result = system("chef-solo -c #{chefsolo_config_file} -j #{chefsolo_node_file}")
      if chef_solo_result
        @logger.info('run chef-solo successfully.')
      else
        fail
      end
    end
  end
  # rubocop: enable ClassLength
end

if __FILE__ == $PROGRAM_NAME
  role = ARGV[0]
  event = ARGV[1]
  CloudConductorPattern::EventHandler.new(role).execute(event)
end
