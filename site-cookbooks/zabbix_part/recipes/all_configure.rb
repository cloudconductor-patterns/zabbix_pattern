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

  if node['hostname'] == svr_name then
    node.default.zabbix_part.agent.HostMetadata = svr['roles']

    for var in svr['roles']
      case var
      when "ap" then
        if File.exists?("/etc/sysconfig/tomcat7") then
          execute "hostname on hosts file" do
            not_if "grep #{node['hostname']} /etc/hosts"
            user "root"
            group "root"
            command "sed -i -e '1s/$/ #{node["""hostname"""]}/g' /etc/hosts"
            action :run
          end
          execute "tomcat_catalina_opts" do
            not_if "grep jmxremote /etc/sysconfig/tomcat7"
            user "root"
            group "root"
            command "sed -i -e 's/CATALINA_OPTS=\"/CATALINA_OPTS=\"-Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.rmi.port=12346 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=#{node["""ipaddress"""]} /g' /etc/sysconfig/tomcat7"
            action :run
          end
          service "tomcat7" do
            action [:enable, :restart]
          end
        end
      end
    end
  end

  next unless svr['roles'].include? 'monitoring'

  my_ary = svr['private_ip']
  node.default.zabbix.agent.servers << my_ary
  node.default.zabbix.agent.servers_active << my_ary
end

directory 'Create include_dir' do
  Chef::Log.info "platform is #{node['platform']}"
  path node['zabbix']['agent']['include_dir']
  owner 'root'
  group 'root'
  mode '755'
  recursive true
end

template "#{node['zabbix']['agent']['include_dir']}/#{node['zabbix_part']['agent']['include_conf_name']}" do
  source 'agentd_include.conf.erb'
  owner 'root'
  group 'root'
  mode '755'
  action :create
end

include_recipe 'yum-epel'
include_recipe 'zabbix::agent'
