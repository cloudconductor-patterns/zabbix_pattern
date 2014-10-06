action :import do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    connection.query(
      :method => new_resource.method,
      :params => new_resource.parameters
    )
  end
  @new_resource.updated_by_last_action(true)
end
