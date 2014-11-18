require_relative '../spec_helper'

describe 'zabbix_part::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
    stub_command('which php').and_return(0)
  end

  it 'include setup recipe' do
    expect(chef_run).to include_recipe 'zabbix_part::setup'
  end
end
