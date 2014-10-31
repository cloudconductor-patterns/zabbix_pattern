actions :create
default_action :create

attribute :zabbix_fqdn, kind_of: String, required: true
attribute :login, kind_of: String, required: true
attribute :password, kind_of: String, required: true
attribute :template, kind_of: String, required: true
attribute :action_name, kind_of: String, required: false
attribute :def_shortdata, kind_of: String, required: false, default: 'Auto registration: {HOST.HOST}'
attribute :def_longdata, kind_of: String, required: false,
          default: "Host name: {HOST.HOST}\r\nHost IP: {HOST.IP}\r\nAgent port: {HOST.PORT}"
attribute :host_metadata, kind_of: Array, required: false, default: []
