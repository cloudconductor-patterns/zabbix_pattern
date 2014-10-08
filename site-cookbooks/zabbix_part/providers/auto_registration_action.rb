action :create do

  server_connection = {
    :url => "http://#{new_resource.zabbix_fqdn}/api_jsonrpc.php",
    :user => new_resource.login,
    :password => new_resource.password
  }

  Chef::Zabbix.with_connection(server_connection) do |connection|
    template_ids = Zabbix::API.find_template_ids(connection, new_resource.template)
    if template_ids.empty?
      Chef::Application.fatal! "Could not find a template named #{new_resource.template}"
    end

   params = {
     :name => new_resource.action_name ? new_resource.action_name : new_resource.name,
     :eventsource => "2",
     :evaltype => "0",
     :status => "0",
     :esc_period => "0",
     :def_shortdata => 'Auto registration: {HOST.HOST}',
     :def_longdata => 'Host name: {HOST.HOST}\r\nHost IP: {HOST.IP}\r\nAgent port: {HOST.PORT}',
     :recovery_msg => '0',
     :r_shortdata => '',
     :r_longdata => '',
     :operations => [
       {
         :operationtype => '2',
         :esc_period => '0',
         :esc_step_from => '1',
         :esc_step_to => '1',
         :evaltype => '0'
       },{
         :operationtype => '6',
         :esc_period => '0',
         :esc_step_from => '1',
         :esc_step_to => '1',
         :evaltype => '0',
         :optemplate => [
           {
             :templateid => template_ids.first["templateid"]

           }
         ]
       }
     ]
   }

   if new_resource.host_metadata
     params[:conditions] = [
       {
         :conditiontype => 24,
         :operator => 2,
         :value => new_resource.host_metadata
       }
     ]
   end

    connection.query(
      :method => "action.create",
      :params => params
    )

  end
  @new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
