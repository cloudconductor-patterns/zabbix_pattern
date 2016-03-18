include_attribute 'zabbix_part::agent'

default['zabbix']['agent']['prebuild']['arch']  = node['kernel']['machine'] == 'x86_64' ? 'amd64' : 'i386'
default['zabbix']['agent']['prebuild']['url']      = "http://www.zabbix.com/downloads/#{node['zabbix']['agent']['version']}/zabbix_agents_#{node['zabbix']['agent']['version']}.linux2_6.#{node['zabbix']['agent']['prebuild']['arch']}.tar.gz"
default['zabbix']['agent']['checksum'] = 'b3e37a5126173cac211d96d791ba1046cec0764d6aa1b8ad75e343d5a2543dda'
