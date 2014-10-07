#
# Cookbook Name:: zabbix_part
# Recipe:: all_configure
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
directory node['zabbix']['agent']['include_dir'] do
  Chef::Log.info "platform is #{node['platform']}"
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
