#
# Cookbook Name:: zabbix_part
# Recipe:: import
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node['zabbix']['web']['fqdn']
  zabbix_server = node
else
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  Chef::Log.warn("If you did not set node['zabbix']['web']['fqdn'], the recipe will fail")
  return
end

zabbix_part_auto_registration_action 'auto_registration_action_sample' do
  action :create
  zabbix_fqdn zabbix_server['zabbix']['web']['fqdn']
  login       zabbix_server['zabbix']['web']['login']
  password    zabbix_server['zabbix']['web']['password']
  template    'Template OS Linux'
end
