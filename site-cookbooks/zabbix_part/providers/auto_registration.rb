action :create do

  server_connection = {
    url: "http://#{new_resource.zabbix_fqdn}/api_jsonrpc.php",
    user: new_resource.login,
    password: new_resource.password
  }

  Chef::Zabbix.with_connection(server_connection) do |connection|

    # delete if there is action with same name
    connection.query(
      method: 'action.get',
      params: {
        output: 'actionids',
        filter: {
          name: new_resource.action_name ||  new_resource.name
        }
      }
    ).each do |result|
      connection.query(
        method: 'action.delete',
        params: [result['actionid']]
      )
    end

    template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
    Chef::Application.fatal! "Could not find a template named #{new_resource.template}" if template_ids.empty?

    params = {
      name: new_resource.action_name || new_resource.name,
      eventsource: '2',
      evaltype: '0',
      esc_period: '0',
      def_shortdata: new_resource.def_shortdata,
      def_longdata: new_resource.def_longdata,
      operations: [
        {
          operationtype: '2'
        }, {
          operationtype: '6',
          optemplate: [
            {
              templateid: template_ids.first['templateid']
            }
          ]
        }
      ],
      conditions: []
    }

    new_resource.host_metadata.each do |metadata|
      params[:conditions].push(
        conditiontype: 24,
        operator: 2,
        value: metadata
      )
    end

    connection.query(
      method: 'action.create',
      params: params
    )

  end
  @new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
