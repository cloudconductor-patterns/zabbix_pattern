require_relative '../spec_helper'

describe 'zabbix_part::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
    stub_command('which php').and_return(0)

    chef_run.node.set['zabbix']['web']['fqdn'] = 'chefspec.local'
    chef_run.node.set['zabbix']['web']['login'] = 'chefs'
    chef_run.node.set['zabbix']['web']['password'] = 'passwd'
    chef_run.converge(described_recipe)
  end

  it 'install mysql-devel package' do
    expect(chef_run).to install_package('mysql-devel')
  end

  it 'include database::mysql recipe' do
    expect(chef_run).to include_recipe 'database::mysql'
  end

  it 'include mysql::server recipe' do
    expect(chef_run).to include_recipe 'mysql::server'
  end

  it 'include zabbix::default recipe' do
    expect(chef_run).to include_recipe 'zabbix'
  end

  it 'include zabbix::database recipe' do
    expect(chef_run).to include_recipe 'zabbix::database'
  end

  it 'include zabbix::server recipe' do
    expect(chef_run).to include_recipe 'zabbix::server'
  end

  it 'include zabbix::web recipe' do
    expect(chef_run).to include_recipe 'zabbix::web'
  end

  it 'include zabbix::java_gateway recipe' do
    expect(chef_run).to include_recipe 'zabbix::java_gateway'
  end

  it 'include apache2::mod_php5 recipe' do
    expect(chef_run).to include_recipe 'apache2::mod_php5'
  end

  it 'Apache2 service resource is loaded from a default recipe of apache2 cookbooks' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(:service, :enable, 'apache2')
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(:service, :start, 'apache2').with(
      supports: { restart: true, reload: true, status: true, start: true },
      cookbook_name: :apache2,
      recipe_name: 'default'
    )
  end

  it 'restart apache2 service immediately' do
    expect(chef_run).to run_ruby_block('restart_apache2')
    block = chef_run.ruby_block('restart_apache2')
    expect(block).to notify('service[apache2]').to(:restart).immediately
  end

  it 'unset env http_proxy and https_proxy' do
    expect(ENV).to receive(:[]=).with('http_proxy', nil)
    expect(ENV).to receive(:[]=).with('https_proxy', nil)
    chef_run.ruby_block('unset_proxy').old_run_action(:create)
  end

  it 'import a zbx_template.xml to the zabbix server' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :zabbix_part_import_template,
      :import,
      'zbx_template.xml'
    ).with(
      zabbix_fqdn: 'chefspec.local',
      login: 'chefs',
      password: 'passwd',
      source: 'zbx_template.xml'
    )
  end

  it 'create auto_registration action to zabbix server' do
    chef_run.node.set['zabbix_part']['auto_registration']['template'] = 'template.xml'
    chef_run.converge(described_recipe)

    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :zabbix_part_auto_registration,
      :create,
      'create auto_registration action'
    ).with(
      zabbix_fqdn: 'chefspec.local',
      login: 'chefs',
      password: 'passwd',
      template: 'template.xml'
    )
  end

  it 'set env http_proxy and https_proxy' do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('http_proxy').and_return('127.0.0.100')
    allow(ENV).to receive(:[]).with('https_proxy').and_return('127.0.0.101')
    chef_run.converge(described_recipe)
    expect(ENV).to receive(:[]=).with('http_proxy', '127.0.0.100')
    expect(ENV).to receive(:[]=).with('https_proxy', '127.0.0.101')
    chef_run.ruby_block('set_proxy').old_run_action(:create)
  end
end
