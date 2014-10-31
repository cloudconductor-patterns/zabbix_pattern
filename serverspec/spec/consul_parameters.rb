require 'net/http'
require 'json'
require 'base64'
require 'active_support'
require 'net/http'
require 'uri'

module ConsulParameters
  def read
    parameters = {}
    begin
      response = Net::HTTP.get URI.parse('http://localhost:8500/v1/kv/cloudconductor/parameters')
      response_hash = JSON.parse(response, symbolize_names: true).first
      parameters_json = Base64.decode64(response_hash[:Value])
      parameters = JSON.parse(parameters_json, symbolize_names: true)
    rescue => exception
      p exception.message
    end
    parameters
  end

  def read_servers
    begin
      servers = {}
      response = Net::HTTP.get URI.parse('http://localhost:8500/v1/kv/cloudconductor/servers?recurse')
      JSON.parse(response, symbolize_names: true).each do |response_hash|
        key = response_hash[:Key]
        next if key == 'cloudconductor/servers'
        hostname = key.slice(%r{cloudconductor/servers/(?<hostname>[^/]*)}, 'hostname')
        server_info_json = Base64.decode64(response_hash[:Value])
        servers[hostname] = JSON.parse(server_info_json, symbolize_names: true)
      end
    rescue
      servers = {}
    end
    servers
  end
end
