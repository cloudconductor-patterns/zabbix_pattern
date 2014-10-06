actions :import
default_action :import

attribute :server_connection, :kind_of => Hash, :required => true
attribute :file, :kind_of => String, :required => true
