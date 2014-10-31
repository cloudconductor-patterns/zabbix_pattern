#
# Cookbook Name:: zabbix_part
# Recipe:: setup
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'mysql-devel' do
  action :install
end

include_recipe 'database::mysql'
include_recipe 'mysql::server'
include_recipe 'zabbix'
include_recipe 'zabbix::database'
include_recipe 'zabbix::server'
include_recipe 'zabbix::web'
include_recipe 'apache2::mod_php5'

if node['zabbix']['web']['fqdn']
  zabbix_server = node
else
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  Chef::Log.warn("If you did not set node['zabbix']['web']['fqdn'], the recipe will fail")
  return
end

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
