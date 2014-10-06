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
include_recipe 'zabbix_part::import'
