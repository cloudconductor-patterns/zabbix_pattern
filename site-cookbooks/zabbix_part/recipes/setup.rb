#
# Cookbook Name:: zabbix_part
# Recipe:: setup
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'build-essential::default'
include_recipe 'mysql::server'
include_recipe 'mysql::client'
include_recipe 'database::mysql'
include_recipe 'zabbix'
include_recipe 'zabbix::database'
include_recipe 'zabbix::server'
include_recipe 'zabbix::web'
include_recipe 'apache2::mod_php5'


zabbix_server = node

ruby_block 'restart_apache2' do
  block {}
  notifies :restart, 'service[apache2]', :immediately
end

original_http_proxy = ENV['http_proxy']
original_https_proxy = ENV['https_proxy']

ruby_block 'unset_proxy' do
  block do
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil
  end
end

zabbix_part_import_template 'zbx_template.xml' do
  zabbix_fqdn zabbix_server['zabbix']['web']['fqdn']
  login  zabbix_server['zabbix']['web']['login']
  password zabbix_server['zabbix']['web']['password']
  source 'zbx_template.xml'
end

zabbix_part_auto_registration 'create auto_registration action' do
  action :create
  zabbix_fqdn zabbix_server['zabbix']['web']['fqdn']
  login       zabbix_server['zabbix']['web']['login']
  password    zabbix_server['zabbix']['web']['password']
  template    node['zabbix_part']['auto_registration']['template']
end

ruby_block 'set_proxy' do
  block do
    ENV['http_proxy'] = original_http_proxy
    ENV['https_proxy'] = original_https_proxy
  end
end

directory 'Create attach_template' do
  Chef::Log.info "platform is #{node['platform']}"
  path node['zabbix_part']['consul']['event_handlers_dir']
  owner 'root'
  group 'root'
  mode '755'
  recursive true
end

template "#{node['zabbix_part']['consul']['consul_dir']}/zabbix_pattern.json" do
  source 'zabbix_pattern.json.erb'
  owner 'root'
  group 'root'
  mode '755'
  action :create
end

filenames = %w(attach_template.sh attach_template.py zabbix_api.py template_list.json config.json)
filenames.each do |filename|
  template "#{node['zabbix_part']['consul']['event_handlers_dir']}/#{filename}" do
    source "#{filename}.erb"
    owner 'root'
    group 'root'
    mode '755'
    action :create
  end
end
