require 'serverspec'

set :backend, :exec

require 'consul_parameters'

include ConsulParameters
properties = { consul_parameters: read, servers: read_servers }

RSpec.configure do |c|
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask('Enter sudo password: ') { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end

  set_property properties
end
