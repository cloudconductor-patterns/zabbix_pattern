require_relative '../spec_helper'

describe 'zabbix_part::setup' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      cookbook_path: ['site-cookbooks', 'cookbooks'],
      platform:      'centos',
      version:       '6.5'
    ).converge(described_recipe)
  end

  before do
    stub_command("/usr/sbin/httpd -t").and_return(0)
    stub_command("which php").and_return(0)
  end

  it 'installs a package' do
    expect(chef_run).to install_package('mysql-devel')
  end

  it 'include recipes' do
    expect(chef_run).to include_recipe 'database::mysql'
    expect(chef_run).to include_recipe 'mysql::server'
    expect(chef_run).to include_recipe 'zabbix::default'
    expect(chef_run).to include_recipe 'zabbix::database'
    expect(chef_run).to include_recipe 'zabbix::server'
    expect(chef_run).to include_recipe 'zabbix::web'
    expect(chef_run).to include_recipe 'apache2::mod_php5'
    expect(chef_run).to include_recipe 'zabbix_part::import'
  end
end

