actions :create
default_action :create

attribute :zabbix_fqdn, :kind_of => String, :required => true
attribute :login, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :template, :kind_of => String, :required => true
attribute :action_name, :kind_of => String, :required => false
attribute :host_metadata, :kind_of => String, :required => false
