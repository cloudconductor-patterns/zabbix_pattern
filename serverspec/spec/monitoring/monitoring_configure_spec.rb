require 'spec_helper'

describe service('httpd') do
  it { should be_enabled }
end

describe service('mysqld') do
  it { should be_enabled }
end

describe service('zabbix_agentd') do
  it { should be_enabled }
end

describe service('zabbix_server') do
  it { should be_enabled }
end
