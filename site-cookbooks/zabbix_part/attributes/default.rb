
include_attribute 'zabbix'

default['zabbix']['server']['version'] = '2.2.6'
default['zabbix']['web']['install_method'] = 'apache'
default['zabbix']['web']['fqdn'] = 'localhost'
default['zabbix']['database']['dbpassword'] = 'ilikerandompasswords'
default['zabbix']['agent']['hostname'] = node['hostname']

default['zabbix_part']['auto_registration']['template'] = 'Template OS Linux'
default['zabbix_part']['agent']['include_conf_name'] = 'HostMetadata.conf'
default['zabbix_part']['agent']['HostMetadata'] = []

default['mysql']['version'] = '5.6'
