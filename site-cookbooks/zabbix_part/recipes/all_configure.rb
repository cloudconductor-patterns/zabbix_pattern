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

  if node['hostname'] == svr_name
    node.default.zabbix_part.agent.HostMetadata = svr['roles']

    svr['roles'].each do |var|
      case var
      when 'ap' then
        if File.exist?('/etc/sysconfig/tomcat7')
          execute 'hostname on hosts file' do
            not_if "grep #{node['hostname']} /etc/hosts"
            user 'root'
            group 'root'
            command "sed -i -e '1s/$/ #{node['''hostname''']}/g' /etc/hosts"
            action :run
          end

          jmxremote_port = ' -Dcom.sun.management.jmxremote.port=#{node['zabbix_part']['jmxremote']['port']}'
          jmxremote_rmi_port = ' -Dcom.sun.management.jmxremote.rmi.port=12346'
          jmxremote_authenticate = ' -Dcom.sun.management.jmxremote.authenticate=false'
          jmxremote_ssl = ' -Dcom.sun.management.jmxremote.ssl=false'
          rmi_server_hostname = " -Djava.rmi.server.hostname=#{node['ipaddress']}"
          catalina_opts = jmxremote_port + jmxremote_rmi_port + jmxremote_authenticate + jmxremote_ssl + rmi_server_hostname

          execute 'tomcat_catalina_opts' do
            not_if 'grep jmxremote /etc/sysconfig/tomcat7'
            user 'root'
            group 'root'
            command "sed -i -e 's/CATALINA_OPTS=\"/CATALINA_OPTS=\" #{catalina_opts}/g' /etc/sysconfig/tomcat7"
            action :run
          end
          service 'tomcat7' do
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
include_recipe 'zabbix_part::agent'
