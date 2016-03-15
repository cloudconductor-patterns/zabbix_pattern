action :import do
  filename = ::File.basename(new_resource.source)
  temporary_path = "#{Chef::Config[:file_cache_path]}/#{filename}"

  f = cookbook_file temporary_path do
    source new_resource.source
  end

  f.run_action(:create)

  template_xml = open(temporary_path).read

  params = {
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

  server_connection = {
    url: "http://#{new_resource.zabbix_fqdn}/api_jsonrpc.php",
    user: new_resource.login,
    password: new_resource.password
  }

  zabbix_api_call new_resource.name do
    action :call
    server_connection server_connection
    method 'configuration.import'
    parameters params
  end

  new_resource.updated_by_last_action(true)
end
