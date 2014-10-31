require_relative '../spec_helper'

describe 'zabbix_part::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ).converge(described_recipe)
  end

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
    stub_command('which php').and_return(0)
  end

  it 'install mysql-devel' do
    expect(chef_run).to install_package('mysql-devel')
  end

  it 'include database::mysql' do
    expect(chef_run).to include_recipe 'database::mysql'
  end

  it 'include mysql::server' do
    expect(chef_run).to include_recipe 'mysql::server'
  end

  it 'include zabbix::default' do
    expect(chef_run).to include_recipe 'zabbix'
  end

  it 'include zabbix::database' do
    expect(chef_run).to include_recipe 'zabbix::database'
  end

  it 'include zabbix::server' do
    expect(chef_run).to include_recipe 'zabbix::server'
  end

  it 'include zabbix::web' do
    expect(chef_run).to include_recipe 'zabbix::web'
  end

  it 'include apache2::mod_php5' do
    expect(chef_run).to include_recipe 'apache2::mod_php5'
  end

  it 'import zabbix template' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :zabbix_part_import_template,
      :import,
      'zbx_template.xml'
    ).with(
      zabbix_fqdn: 'localhost',
      login: 'admin',
      password: 'zabbix',
      source: 'zbx_template.xml'
    )
  end

  it 'create augo_registration action' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :zabbix_part_auto_registration,
      :create,
      'create auto_registration action'
    ).with(
      zabbix_fqdn: 'localhost',
      login: 'admin',
      password: 'zabbix',
      template: 'Template OS Linux'
    )
  end
end
