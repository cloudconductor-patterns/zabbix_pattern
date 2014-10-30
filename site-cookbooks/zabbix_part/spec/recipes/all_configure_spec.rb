require_relative '../spec_helper'
require 'chefspec'

describe 'zabbix_part::all_configure' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(cookbooks site-cookbooks),
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['servers']['zbx_agt'] = {
        roles: ''
      }
      node.set['cloudconductor']['servers']['zbx_svr'] = {
        roles: 'monitoring',
        private_ip: '127.0.0.1'
      }
      node.set['zabbix_part']['agent']['include_dir']\
      = '/etc/zabbix/agent_include'
      node.set['zabbix_part']['agent']['include_conf_name']\
      = 'HostMetadata.conf'
      node.set['zabbix_part']['agent']['HostMetadata'] = ''
    end.converge 'zabbix_part::all_configure'
  end

  # Create default_root
  it 'Create Directory' do
    expect(chef_run).to create_directory('/etc/zabbix/agent_include').with(
      owner: 'root', group: 'root', mode: '755'
    )
  end

  # Create HostMetadata.conf for zabbix_agentd from template
  let(:template) do
    chef_run.template('/etc/zabbix/agent_include/HostMetadata.conf')
  end
  it 'Create zabbix agent config file from template' do
    expect(chef_run).to create_template(
      '/etc/zabbix/agent_include/HostMetadata.conf'
    ).with(mode: '755')
  end
  it 'Check HostMetadata.conf' do
    expect(chef_run).to render_file('/etc/zabbix/agent_include/HostMetadata.conf').with_content(/^HostMetadata=/)
  end

  # Include recipe yum-epel
  it 'Include recipe for yum-epel' do
    expect(chef_run).to include_recipe 'yum-epel'
  end

  # Include recipe zabbix::agent
  it 'Include recipe for zabbix::agent' do
    expect(chef_run).to include_recipe 'zabbix::agent'
  end
end
