actions :import
default_action :import

attribute :zabbix_fqdn, kind_of: String, required: true
attribute :login, kind_of: String, required: true
attribute :password, kind_of: String, required: true
attribute :source, kind_of: String, required: true
