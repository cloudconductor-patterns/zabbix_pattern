require_relative '../spec_helper'
require 'chefspec'

describe 'zabbix_part::all_configure' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    chef_run.node.automatic[:hostname] = 'zbx_svr'
    chef_run.node.set['cloudconductor']['servers']['zbx_svr'] = {
      roles: ['monitoring'],
      private_ip: '127.0.0.1'
    }
    chef_run.converge(described_recipe)
  end

  it 'zabbix cookbook attribute is a excepting case of windows platform' do
    expect(chef_run.node[:zabbix][:etc_dir]).to eq('/etc/zabbix')
    expect(chef_run.node[:zabbix][:agent][:include_dir]).to eq('/etc/zabbix/agent_include')
  end

  it 'local servers role is put on attribute of zabbix_part.agent.hostmetadata' do
    expect(chef_run.node[:zabbix_part][:agent][:HostMetadata]).to eq(['monitoring'])
  end

  it 'only zabbix servers private ip is put on attribute of servers and servers_active' do
    chef_run.node.set['cloudconductor']['servers']['ap_svr'] = {
      roles: ['ap'],
      private_ip: '127.0.0.2'
    }
    chef_run.converge(described_recipe)

    expect(chef_run.node[:zabbix][:agent][:servers]).to match_array ['127.0.0.1']
    expect(chef_run.node[:zabbix][:agent][:servers_active]).to match_array ['127.0.0.1']
  end

  it 'create a config directory of including for zabbix agent' do
    expect(chef_run).to create_directory('/etc/zabbix/agent_include').with(
      owner: 'root',
      group: 'root',
      mode: '755'
    )
  end

  it 'create a including config file for zabbix agent' do
    chef_run.node.set['zabbix_part']['agent']['include_conf_name'] = 'host_metadata.conf'
    chef_run.converge(described_recipe)

    expect(chef_run).to create_template('/etc/zabbix/agent_include/host_metadata.conf').with(
      source: 'agentd_include.conf.erb',
      owner: 'root',
      group: 'root',
      mode: '755'
    )
  end

  it 'local server of the role is written as a host metadata to include config file' do
    chef_run.node.set['zabbix_part']['agent']['include_conf_name'] = 'host_metadata.conf'
    chef_run.converge(described_recipe)

    expect(chef_run).to render_file('/etc/zabbix/agent_include/host_metadata.conf').with_content(/^HostMetadata=\["monitoring"\]/)
  end

  it 'include yum-epel recipe' do
    expect(chef_run).to include_recipe 'yum-epel'
  end

  it 'include zabbix::agent recipe' do
    expect(chef_run).to include_recipe 'zabbix::agent'
  end

  describe 'multiple of zabbix server is available' do
    it 'only zabbix servers private ip is put on attribute of servers and servers_active' do
      chef_run.node.set['cloudconductor']['servers']['ap_svr'] = {
        roles: ['ap'],
        private_ip: '127.0.0.2'
      }
      chef_run.node.set['cloudconductor']['servers']['zbx_svr2'] = {
        roles: ['monitoring'],
        private_ip: '127.0.0.3'
      }
      chef_run.converge(described_recipe)

      expect(chef_run.node[:zabbix][:agent][:servers]).to match_array ['127.0.0.1', '127.0.0.3']
      expect(chef_run.node[:zabbix][:agent][:servers_active]).to match_array ['127.0.0.1', '127.0.0.3']
    end
  end
end
