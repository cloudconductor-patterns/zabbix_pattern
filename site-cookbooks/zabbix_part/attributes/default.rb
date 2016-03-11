
include_attribute 'zabbix'

default['zabbix']['server']['version'] = '2.2.11'
default['zabbix']['server']['java_pollers'] = '3'
default['zabbix']['server']['java_gateway_enable'] = true
default['zabbix']['server']['java_gateway_port'] = 10052
default['zabbix']['web']['install_method'] = 'apache'
default['zabbix']['web']['fqdn'] = 'localhost'
default['zabbix']['database']['dbpassword'] = 'ilikerandompasswords'
default['zabbix']['agent']['hostname'] = node['hostname']

default['zabbix_part']['auto_registration']['template'] = 'Template OS Linux'
default['zabbix_part']['agent']['include_conf_name'] = 'HostMetadata.conf'
default['zabbix_part']['agent']['HostMetadata'] = []
default['zabbix_part']['consul']['consul_dir'] = '/etc/consul.d'
default['zabbix_part']['consul']['event_handlers_dir'] = '/opt/consul/attach_template'

default['zabbix_part']['agent']['port'] = '10050'
default['zabbix_part']['snmp']['port'] = '161'
default['zabbix_part']['ipmi']['port'] = '623'
default['zabbix_part']['discovered']['group'] = 'Discovered hosts'

default['zabbix_part']['jmxremote']['port'] = '12345'

default['mysql']['version'] = '5.6'
default['mysql']['enable_utf8'] = 'true'

default['java']['jdk_version'] =
  case node[:playform_family]
  when 'rhel'
    node['platform_version'].to_f >= 7.0 ? '7' : '8'
  else
    '7'
  end
