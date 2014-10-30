#
# Cookbook Name:: zabbix_part
# Recipe:: all_configure
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

# Set attribute data
node['cloudconductor']['servers'].each do |svr_name, svr|
  Chef::Log.info 'Set attribute data '
  node.default.zabbix_part.agent.HostMetadata = "#{svr['roles']}" if node['hostname'] == svr_name
  next unless svr['roles'].include? 'monitoring'

  my_ary = "#{svr['private_ip']}"
  node.default.zabbix.agent.servers << my_ary
  node.default.zabbix.agent.servers_active << my_ary
end

directory 'Create include_dir' do
  Chef::Log.info "platform is #{node['platform']}"
  path node['zabbix']['agent']['include_dir']
  unless node['platform'] == 'windows'
    owner 'root'
    group 'root'
    mode '755'
  end
  recursive true
end

template "#{node['zabbix']['agent']['include_dir']}/#{node['zabbix_part']['agent']['include_conf_name']}" do
  source 'agentd_include.conf.erb'
  unless node['platform'] == 'windows'
    owner 'root'
    group 'root'
    mode '755'
  end
  action :create
end

include_recipe 'yum-epel'
include_recipe 'zabbix::agent'
