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
include_recipe 'zabbix_part::import_template'

if node['zabbix']['web']['fqdn']
  zabbix_server = node
else
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  Chef::Log.warn("If you did not set node['zabbix']['web']['fqdn'], the recipe will fail")
  return
end

zabbix_part_auto_registration 'auto_registration_action_sample' do
  action :create
  zabbix_fqdn zabbix_server['zabbix']['web']['fqdn']
  login       zabbix_server['zabbix']['web']['login']
  password    zabbix_server['zabbix']['web']['password']
  template    'Template OS Linux'
end
