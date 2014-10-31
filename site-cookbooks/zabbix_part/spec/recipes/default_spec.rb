require_relative '../spec_helper'

describe 'zabbix_part::default' do
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

  it 'include recipe zabbix_part::setup' do
    expect(chef_run).to include_recipe 'zabbix_part::setup'
  end
end
