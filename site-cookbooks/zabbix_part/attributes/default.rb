include_attribute 'zabbix_part'

default['zabbix']['version'] = '2.2.11'

default['zabbix']['database']['dbpassword'] = 'ilikerandompasswords'

case node['platform_family']
when 'windows'
  if ENV['ProgramFiles'] == ENV['ProgramFiles(x86)']
    # if user has never logged into an interactive session then ENV['homedrive'] will be nil
    default['zabbix']['etc_dir']    = ::File.join((ENV['homedrive'] || 'C:'), 'Program Files', 'Zabbix Agent')  else
    default['zabbix']['etc_dir']    = ::File.join(ENV['ProgramFiles'], 'Zabbix Agent')
  end
else
  default['zabbix']['etc_dir']      = '/etc/zabbix'
end
default['zabbix']['install_dir']  = '/opt/zabbix'
default['zabbix']['web_dir']      = '/opt/zabbix/web'
default['zabbix']['external_dir'] = '/opt/zabbix/externalscripts'
default['zabbix']['alert_dir']    = '/opt/zabbix/AlertScriptsPath'
default['zabbix']['lock_dir']     = '/var/lock/subsys'
default['zabbix']['src_dir']      = '/opt'
default['zabbix']['log_dir']      = '/var/log/zabbix'
default['zabbix']['run_dir']      = '/var/run/zabbix'

default['zabbix']['login']  = 'zabbix'
default['zabbix']['group']  = 'zabbix'
default['zabbix']['uid']    = nil
default['zabbix']['gid']    = nil
default['zabbix']['home']   = '/opt/zabbix'
default['zabbix']['shell']  = '/bin/bash'

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
