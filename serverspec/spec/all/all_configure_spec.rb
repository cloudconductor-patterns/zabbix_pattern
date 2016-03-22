require_relative '../spec_helper.rb'

describe service('zabbix_agentd') do
  it { should be_enabled }
end

describe port(10_050) do
  it { should be_listening.with('tcp') }
end

describe 'connect jmx_server' do
  servers = property[:servers]
  servers.each do |svr_name, server|
    server.each do |var|
      case var
      when 'ap' then
        if File.exist?('/etc/sysconfig/tomcat7')
          describe "#{svr_name} access check" do
            describe host(server[:private_ip]) do
              it { should be_reachable.with(port: 12345) }
              it { should be_reachable.with(port: 12346) }
            end
          end
        end
      end
    end
  end
end

describe 'connect zbx_server' do
  servers = property[:servers]

  servers.each do |svr_name, server|
    next unless server[:roles] == 'monitoring'
    describe "#{svr_name} access check" do
      describe host(server[:private_ip]) do
        it { should be_reachable.with(port: 10051) }
      end
    end
  end
end
