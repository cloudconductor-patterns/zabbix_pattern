require_relative '../spec_helper.rb'

describe service('zabbix_agentd') do
  it { should be_enabled }
end

describe port(10_050) do
  it { should be_listening.with('tcp') }
end

describe 'connect zbx_server' do

  servers = property[:servers]

  servers.each do |svr_name, server|
    next unless server[:roles] == 'monitoring'
    describe "#{svr_name} access check" do
      describe command("hping3 -S #{server[:private_ip]} -p 10051 -c 5") do
        its(:stdout) { should match '/sport=10051 flags=SA/' }
      end
    end
  end
end
