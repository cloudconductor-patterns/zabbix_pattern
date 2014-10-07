#
# Cookbook Name:: zabbix_part
# Recipe:: import_template
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

api_connection_info = {
  url:  "http://#{zabbix_server['zabbix']['web']['fqdn']}/api_jsonrpc.php",
  user: zabbix_server['zabbix']['web']['login'],
  password: zabbix_server['zabbix']['web']['password']
}

cb = run_context.cookbook_collection[cookbook_name]
cb.manifest['files'].each do |cookbookfile|
  if cookbookfile['specificity'] == 'zabbix'
    path = File.expand_path("../../files/#{cookbookfile['specificity']}/#{cookbookfile['name']}", __FILE__)
    template_xml = open(path).read

    parameters = {
      format: 'xml',
      source: template_xml,
      rules: {
        items: { createMissing: true },
        applications: { createMissing: true },
        graphs: { createMissing: true },
        groups: { createMissing: true },
        templateLinkage: { createMissing: true },
        templates: { createMissing: true },
        triggers: { createMissing: true }
      }
    }

    zabbix_api_call cookbookfile['name'] do
      action :call
      server_connection api_connection_info
      method 'configuration.import'
      parameters parameters
    end
  end
end
