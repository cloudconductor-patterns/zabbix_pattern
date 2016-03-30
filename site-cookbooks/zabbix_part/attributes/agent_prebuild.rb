include_attribute 'zabbix_part::agent'

default['zabbix']['agent']['prebuild']['arch'] = node['kernel']['machine'] == 'x86_64' ? 'amd64' : 'i386'
zabbix_version = node['zabbix']['agent']['version']
zabbix_arch = node['zabbix']['agent']['prebuild']['arch']
zabbix_url = "http://www.zabbix.com/downloads/#{zabbix_version}/zabbix_agents_#{zabbix_version}.linux2_6.#{zabbix_arch}.tar.gz"
default['zabbix']['agent']['prebuild']['url'] = zabbix_url
default['zabbix']['agent']['checksum'] = 'b3e37a5126173cac211d96d791ba1046cec0764d6aa1b8ad75e343d5a2543dda'
